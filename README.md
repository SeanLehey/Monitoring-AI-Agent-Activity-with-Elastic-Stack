# Monitoring AI Agent Activity with Elastic Stack
_Project in Progress_

> [!NOTE]
> See my [AI ethics statement](https://github.com/SeanLehey/Personal-AI-Ethics-Statement) for how I use, and don't use, AI for certain tasks.

## Project Overview
As more companies provision licenses for AI tools, and as those tools become more autonomous, I believe it's prudent to learn how to closely monitor agentic activity within enterprise environments. This project is intended to demonstrate what key activity to look out for, and how to pipe this data into an analytics platform of your choice (in this case, Elastic Stack). We will be examining Sysmon activity attributed to the Claude Desktop executable, along with Claude's hook events for more granular insight into agentic actions.

## Resources Used
* [Windows 11 Home (25H2)](https://www.microsoft.com/en-us/software-download/windows11)
* [Anthropic's Hooks Documentation](https://code.claude.com/docs/en/hooks)
* [Elasticsearch](https://www.elastic.co/downloads/elasticsearch)
* [Kibana](https://www.elastic.co/downloads/kibana)
* [Filebeat](https://www.elastic.co/downloads/beats/filebeat)
* [Winlogbeat](https://www.elastic.co/downloads/beats/winlogbeat)
* [Claude Desktop](https://claude.com/download)
* [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)

Ensure your Elastic Stack component versions match (I used version 9.5.5 for this project).

## Setting Things Up
<details>
<summary>Expand to see ELK and log forwarder configuration</summary>

## Enabling and Starting Sysmon
On Windows 11 Home, you can enable enable Sysmon via the shortcut `Windows+R` and typing `optionalfeatures`. Here you will simply tick the checkbox to enable Sysmon.

<img width="892" height="782" alt="image" src="https://github.com/user-attachments/assets/3b3b03a3-057d-4f53-8751-4956083ed5a5" />

Then, in a privileged terminal, type `sysmon -i` to install and start the Sysmon service. After downloading `sysmon-claude.xml` from this repo and saving it to your ELK folder, you can apply it as a configuration file by typing `sysmon -c C:\ELK\sysmon-claude.xml`.

This configuration file allows us to log activity attributed to Claude such as Git Bash usage, network connections, and child processes.

## Installing ELK
Start by downloading the four ELK components above in any order. Then install as follows:

#### Elasticsearch
Extract the contents of `elasticsearch-9.5.5-windows-x86_64` to a location of your choice - in this case, we will extract to `C:\ELK\`.

<img width="1414" height="302" alt="image" src="https://github.com/user-attachments/assets/91adfd56-66aa-4adb-935d-1b88fd51440b" />

Then open a terminal, run `cd C:\ELK\elasticsearch-9.5.5`, and type `.\bin\elasticsearch.bat`. This will provide you with a password for the `elastic` user as well as an enrollment token you'll need to save for when we launch the web application.

<img width="2512" height="918" alt="image" src="https://github.com/user-attachments/assets/72de2b3a-fe74-423a-a0b4-76dec533f9ca" />

#### Kibana
Extract the contents of `kibana-9.5.5-windows-x86_64` to `C:\ELK\` just as we did for Elasticsearch.

<img width="1409" height="297" alt="image" src="https://github.com/user-attachments/assets/cd14bdf2-eddc-48f2-851a-c9897ff077b6" />

Open another terminal, run `cd C:\ELK\kibana-9.5.5`, and type `.\bin\kibana.bat`. You will be presented with a URL containing a 6-digit access code:

<img width="2289" height="526" alt="image" src="https://github.com/user-attachments/assets/0ce9f03c-7b7f-4223-ab76-aad4223e5f59" />

Open that URL in a browser of your choice, and paste the enrollment token from our Elasticsearch setup. Then, click _Configure Elastic_.

Note: You will not need the access code for future sessions. Simply visit `http://localhost:5601/` and log in with your credentials from now on.

<img width="1268" height="227" alt="image" src="https://github.com/user-attachments/assets/d44e6914-4063-4135-b748-5d06d512ca07" />

You will then be presented with a login portal. Enter _elastic_ in the username field and paste the password we received during Elasticsearch setup.

<img width="2555" height="1334" alt="image" src="https://github.com/user-attachments/assets/e09149e0-4288-4c15-8988-ac0bde2f899b" />

Logging in will bring us to the home page:

<img width="2557" height="1325" alt="image" src="https://github.com/user-attachments/assets/12291547-b1ec-4d13-a994-6d2ee60aabf6" />

## Filebeat

Download the MSI file from the Filebeat link in the _Resources Used_ section. After completing installation, place `filebeat.yml` into `C:\Program Files\Elastic\Beats\9.5.5\filebeat\`. 

## Extracting and Forwarding Claude Hooks

For this section, we'll be using the files `log-event.ps1` and `settings.json`.

Place `settings.json` into `%USERPROFILE%\.claude\` and place `log-event.ps1` into `%USERPROFILE%\.claude\hooks\` after creating the latter subfolder.

> [!NOTE]
> The `\.claude\` directory will not exist until you have Claude Code perform an agentic action, so be sure to do so in order for the folder to initialize. Ask me how I know!

Now we can start tracking some hooks! I've asked Claude Code to create a simple .txt file.

<img width="1375" height="491" alt="image" src="https://github.com/user-attachments/assets/4dc513c4-0081-417b-868c-612300b0cc02" />

Let's see what this looks like from a security analyst's point of view. Navigate to `%USERPROFILE%\.claude\hook-logs\agent-activity.jsonl` and take a look at each log entry that begins with `{"session_id":`. As we can see, there are three distinct hook events associated with our agentic action.

> [!NOTE]
>The following logs were pretty-printed from single-line JSON and trimmed to demonstrate the core information we're looking for.



</details>

## Understanding Agent Hook Events

Each action performed by Claude is associated with a hook event whose metadata we forward to Elastic for analysis. The following snippets have been trimmed of extraneous fields and pretty-printed for easier reading. Pay particular attention to the `hook_event_name` field. Let's take a closer look.

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
}
```
#### `PostToolUseFailure`
This hook event is logged when a tool use fails. In the following example, I asked Claude Code to perform the `ls` command in a non-existent folder, resulting in a "cannot access" explanation associated with the tool_error value.<br>
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

I tried to produce a PermissionDenied hook event, but the nature of the activity that Anthropic flags as risky or dangerous means I'd be risking my Claude account by attempting to provide you with an example. This is the inert query I entered before finding out it's probably not a good idea to do this on a SaaS model:

<img width="942" height="116" alt="image" src="https://github.com/user-attachments/assets/e39f12bc-f45c-409d-8cbc-be43b1f9547d" />

To be specific, the curl action I attempted did not even make it to the classifier as Claude's response appears to be part of [model-level safeguards](https://support.claude.com/en/articles/8106465-our-approach-to-user-safety):

<img width="1454" height="642" alt="image" src="https://github.com/user-attachments/assets/c15bcb03-688a-4dc0-989d-5b1a0bfd6d13" />

And this was the result of trying to ask about the `other` value associated with the `SessionEnd`hook event:

<img width="1574" height="286" alt="image" src="https://github.com/user-attachments/assets/d13aab67-2c8b-4341-9284-75844ea72ee3" />

</details>

## Creating an Audit Trail

Now that we've set up log forwarding for Sysmon and Claude's hook events, what can we do now? We can correlate! If a security analyst works an alert for a suspicious Bash command, we can now track when that terminal process was created, and whether or not it was the result of a user's query to their agent.

For instance, let's pretend we're investigating some potential reconnaissance activity that was flagged as part of a broader investigation. We want to search for execution of the `whoami` command within the last 15 minutes within our Winlogbeat data view. Doing so yields the following results:

<img width="2560" height="1336" alt="image" src="https://github.com/user-attachments/assets/14133dca-1ce4-4e23-9aa3-c4a58660fc11" />

Drilling down into the earliest of those four events and finding the `winlog.event_data.ParentImage` field produces the following value:

`"C:\Users\Windows01\AppData\Local\Claude-Data\claude_pzs8sxrjxfjjc\claude-code\2.1.309\9078b9c1d466\claude.exe"`

Now that we've confirmed that Claude was responsible for this command, we can gather more context by querying for our hook event data in our Filebeat data view.

<img width="2560" height="1336" alt="image" src="https://github.com/user-attachments/assets/e65d7dd7-91c5-4a22-a9e5-0f7698c0d9da" />

Comparing the timestamps between our search results shows a pretty solid match! 

However, these results only show the `PreToolUse` and `PostToolUse` hook events. Let's expand one of these log entries and filter for the `prompt_id` field, then perform a novel search for that value.

<img width="974" height="342" alt="image" src="https://github.com/user-attachments/assets/79bbc9ae-bbe4-4f0c-aaaf-e7bb79f6c924" />

<img width="2560" height="1336" alt="image" src="https://github.com/user-attachments/assets/1638af97-730f-43ba-ae06-5ac5f2a5703d" />

Voila! This search yields all five relevant hook events, including `UserPromptSubmit`, which will give us further insight into the origins of this command execution.

Drilling down into that field reveals the original query from our user:

<img width="926" height="212" alt="image" src="https://github.com/user-attachments/assets/0032a700-a059-435e-b9b3-032d434c023a" />

At this point, it's simply a matter of correlating the user's role/projects/job duties to the activity, and actioning the alert from there.

## Closing Thoughts

This project has the potential to branch off into a million different directions, but I feel I've completed what I set out to accomplish. We set up logging and forwarding for Sysmon and our hook events, and simulated a basic investigation that utilizes and correlates this data to aid in our conclusion.

Monitoring agent hooks will be of critical importance as more companies allow agents into their environments. Understanding how to interact with this data will be key as more enterprise tools continue to offer these capabilities.

While this was certainly not an exhaustive list of hook events, I feel that I included most of the important ones that would aid in a security analyst's investigation, especially the extremely important `UserPromptSubmit` example. A more robust reporting tool would log all of these, and would likely log chat transcripts as well, though that has some regulatory/data privacy considerations that are beyond the scope of this project.

I hope you enjoyed this writeup and learned a thing or two! Feel free to check out my other projects or reach out with any questions. Thanks!

[Return to Sean's Profile](https://github.com/SeanLehey)
