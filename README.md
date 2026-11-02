# Monitoring AI Agent Activity with Elastic Stack
_Project Completed in November 2026_

> [!NOTE]
> See my [AI ethics statement](https://github.com/SeanLehey/Personal-AI-Ethics-Statement) for how I use, and don't use, AI for certain tasks.

## Project Overview
As more companies provision licenses for AI tools, and as those tools become more autonomous, I believe it's prudent to learn how to closely monitor agentic activity within enterprise environments. This project is intended to demonstrate what key activity to look out for, and how to correlate Claude Code's hook event data with traditional endpoint telemetry from Sysmon to aid in your security investigations.

## Resources Used
* [Windows 11 25H2](https://www.microsoft.com/en-us/software-download/windows11)
* [Anthropic's Hooks Documentation](https://code.claude.com/docs/en/hooks)
* [Elasticsearch](https://www.elastic.co/downloads/elasticsearch)
* [Kibana](https://www.elastic.co/downloads/kibana)
* [Filebeat](https://www.elastic.co/downloads/beats/filebeat)
* [Winlogbeat](https://www.elastic.co/downloads/beats/winlogbeat)
* [Claude Desktop](https://claude.com/download)
* [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)

## Configuration Files
The attached configuration files are intended to serve as baseline reference tools for your environment's configuration. Be sure to replace any placeholder/redacted values if you incorporate them into your own environment. Remember to always use best security practices when working with passwords and other sensitive information.

## Understanding Agent Hook Events

Each action performed by Claude is associated with a hook event whose metadata we forward to Elastic for analysis. The following snippets are sourced from my environment and have been trimmed of extraneous fields and pretty-printed for easier reading. Pay particular attention to the `hook_event_name` field. Let's take a closer look.

#### `SessionStart` and `SessionEnd`

These hook events track the start and end of sessions, and each session is associated with a `session_id` value.<br>
```json
{
  "session_id": "8cfce91b-f771-4978-9414-c60d32c53211",
  "hook_event_name": "SessionStart",
  "session_source": "startup",
  "@timestamp": "2026-11-02T07:40:08.279Z"
}
```

```json
{
  "session_id": "8cfce91b-f771-4978-9414-c60d32c53211",
  "prompt_id": "f656a7e4-4afb-494c-804a-5ef9bb649d7d",
  "hook_event_name": "SessionEnd",
  "reason": "other",
  "@timestamp": "2026-11-02T07:40:47.434Z"
}
```

The SessionEnd hook event above was the result of archiving the chat session, which falls under the "other" value. Attempting to find out what else falls under the "other" value yielded this comically unhelpful table entry from Claude's hook documentation:

<img width="652" height="62" alt="image" src="https://github.com/user-attachments/assets/7ed52051-cf5b-4431-99af-2988dbc3aa44" />

#### `UserPromptSubmit`
This hook event contains the text content of the user's query. <br>
```json
{
  "session_id": "550eb892-041a-4a66-910b-94e27ebb110d",
  "prompt_id": "1f2bcc10-d13f-451b-b624-94ac964ef446",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Please create a .txt file on my Desktop called Hello_world, and type that famous sentence about the quick brown fox as its contents.",
  "session_title": "Agentic Testbed",
  "@timestamp": "2026-10-28T09:50:57.488Z"
}
```
#### `PreToolUse` and `PostToolUse`
The PreToolUse hook fires when an agent makes the decision to use a tool. If this tool usage succeeds, the tool used and the result of that usage is logged during the PostToolUse event. These two hook events produce similar values so I'll just include an example of PostToolUse for brevity's sake:<br>
```json
{
  "session_id": "550eb892-041a-4a66-910b-94e27ebb110d",
  "prompt_id": "1f2bcc10-d13f-451b-b624-94ac964ef446",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "C:\\Users\\Windows01\\Desktop\\Hello_world.txt",
    "content": "The quick brown fox jumps over the lazy dog.\n"
  },
  "tool_response": {
    "type": "create",
    "filePath": "C:\\Users\\Windows01\\Desktop\\Hello_world.txt",
    "content": "The quick brown fox jumps over the lazy dog.\n"
  }
}
```
#### `PostToolUseFailure`
This hook event is logged when a tool use fails. In the following example, I asked Claude Code to perform the `ls` command in a non-existent folder, resulting in a "cannot access" explanation associated with the `tool_error` value.<br>
```json
{
  "session_id": "550eb892-041a-4a66-910b-94e27ebb110d",
  "prompt_id": "a8f7e92d-aa80-4862-a835-3efa3e825782",
  "permission_mode": "auto",
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Bash",
  "tool_input": {
    "command": "ls ~/Desktop/404foldernotfound",
    "description": "List contents of a Desktop subfolder"
  },
  "tool_use_id": "toolu_017MKUY3aCfs8iNsin5WLY1R",
  "tool_error": "Exit code 2\nls: cannot access '/c/Users/Windows01/Desktop/404foldernotfound': No such file or directory",
  "is_interrupt": false,
  "duration_ms": 84,
  "@timestamp": "2026-11-02T06:18:19.100Z"
}
```
#### `PermissionRequest` and `PermissionDenied`
PermissionRequest occurs when a tool invocation requires permission. In this scenario, a safety classifier judges the riskiness of an action and results in either an approval or denial of that action.<br>

[_Actions that the classifier deems as safe proceed automatically, and risky ones get blocked, redirecting Claude to take a different approach. If Claude insists on taking actions that are continually blocked, it will eventually trigger a permission prompt to the user._](https://claude.com/resources/articles/auto-mode)

I tried to produce a PermissionDenied hook event, but the nature of the activity that Anthropic flags as risky or dangerous means I'd be risking my Claude account by attempting to provide you with an example. Any attempts to "exfiltrate" data from my PC or otherwise produce a denial resulted in [model safety notices](https://support.claude.com/en/articles/8106465-our-approach-to-user-safety) that trigger well before the classifier would come into play.

#### `CwdChanged`

Cwd is short for _Current Working Directory_. This hook event fires when Claude changes directories. In this example, we can see that Claude navigated from my Desktop to a folder on my Desktop as a result of one of my requests, as indicated by `old_cwd` and `new_cwd`.

```json
{
  "session_id": "d9cd6be6-40b7-4a3d-a9d0-50f3c0cccfba",
  "prompt_id": "57d4520d-17c5-4958-9fee-e658eb89aa09",
  "hook_event_name": "CwdChanged",
  "old_cwd": "C:\\Users\\Windows01\\Desktop",
  "new_cwd": "C:\\Users\\Windows01\\Desktop\\MainFolder",
  "cwd": "C:\\Users\\Windows01\\Desktop\\MainFolder",
  "@timestamp": "2026-11-02T10:14:27.863Z"
}
```

#### `Stop`

This represents the final hook event for each agent response to a user's query. Of particular note is the `last_assistant_message` field which contains the full text of the agent's response to the user, which could be used to determine how an agent interpreted a user's request.

```json
{
  "session_id": "fc1a1ec7-6fb1-4599-8d21-1cb716b58573",
  "prompt_id": "d09e403f-196a-4f0f-afe8-24da3bebfd8a",
  "permission_mode": "auto",
  "hook_event_name": "Stop",
  "last_assistant_message": "French toast uses bread soaked in a mix of eggs, milk, a little sugar, vanilla, and cinnamon, then fried in butter.",
  "stop_hook_active": false,
  "@timestamp": "2026-11-02T09:44:05.573Z"
}
```

</details>

## Creating an Audit Trail

Now that we've gone over some important hook types, what can we do now? We can correlate! For instance, if a security analyst works an alert for a suspicious Bash command, we can now track when that Bash process was created, and whether or not it was the result of a user's query to their agent.

Let's pretend we're investigating some potential reconnaissance activity that was flagged as part of a broader incident. We want to search for execution of the `whoami` command from the last 15 minutes within our Winlogbeat data view. Doing so yields the following results:

<img width="2560" height="1336" alt="image" src="https://github.com/user-attachments/assets/14133dca-1ce4-4e23-9aa3-c4a58660fc11" />

Drilling down into the earliest of those four events and finding the `winlog.event_data.ParentImage` field produces the following value:

`"C:\Users\Windows01\AppData\Local\Claude-Data\claude_pzs8sxrjxfjjc\claude-code\2.1.309\9078b9c1d466\claude.exe"`

Now that we've confirmed that Claude was responsible for this command, we can gather more context by querying for our hook event data in our Filebeat data view.

<img width="2560" height="1336" alt="image" src="https://github.com/user-attachments/assets/e65d7dd7-91c5-4a22-a9e5-0f7698c0d9da" />

Comparing the timestamps between our search results shows a solid match! 

However, these results only show the `PreToolUse` and `PostToolUse` hook events. Let's expand one of these log entries and filter for the `prompt_id` field, then perform a novel search for that value.

<img width="974" height="342" alt="image" src="https://github.com/user-attachments/assets/79bbc9ae-bbe4-4f0c-aaaf-e7bb79f6c924" />

<img width="2560" height="1336" alt="image" src="https://github.com/user-attachments/assets/1638af97-730f-43ba-ae06-5ac5f2a5703d" />

Voilà! This search yields all five relevant hook events, including `UserPromptSubmit`, which will give us further insight into the origins of this command execution.

Drilling down into that field reveals the original query from our user:

<img width="926" height="212" alt="image" src="https://github.com/user-attachments/assets/0032a700-a059-435e-b9b3-032d434c023a" />

At this point, it's simply a matter of correlating the user's role/projects/job duties to the activity, and actioning the alert with traditional investigative techniques from that point forward.

## Closing Thoughts

Monitoring agent hooks will be of critical importance as more companies allow agents into their environments. Understanding how to interpret this data will be key as more enterprise tools continue to offer these capabilities. While this was certainly not an exhaustive list of hook events, I feel that I included most of the important ones that would aid in a security analyst's investigation, especially the extremely important `UserPromptSubmit` example.

A more robust reporting tool would log more hook events, and would likely log chat transcripts as well, though that has some regulatory/data privacy considerations that are beyond the scope of this project. I'll try to dig deeper in future projects. I hope you enjoyed this writeup and learned a thing or two! Feel free to check out my other projects or reach out with any questions.

[Return to Sean's Profile](https://github.com/SeanLehey)
