# Monitoring AI Agent Activity with Elastic Stack
_Project in Progress_

> [!NOTE]
> See my [AI ethics statement](https://github.com/SeanLehey/Personal-AI-Ethics-Statement) for how I use, and don't use, AI for certain tasks.

## Project Overview
As more companies provision licenses for AI tools, and as those tools become more autonomous, I believe it's prudent to learn how to closely monitor agentic activity within enterprise environments. This project is intended to demonstrate what key activity to look out for, and how to pipe this data into an analytics platform of your choice (in this case, Elastic Stack). We will be examining Sysmon activity attributed to the Claude Desktop executable, along with Claude's [hooks](https://code.claude.com/docs/en/hooks) for more granular activity information.

## Resources Used
* [Windows 11 Home](https://www.microsoft.com/en-us/software-download/windows11)
* [Anthropic's Hooks Documentation](https://code.claude.com/docs/en/hooks)
* [Elasticsearch](https://www.elastic.co/downloads/elasticsearch)
* [Kibana](https://www.elastic.co/downloads/kibana)
* [Filebeat](https://www.elastic.co/downloads/beats/filebeat)
* [Winlogbeat](https://www.elastic.co/downloads/beats/winlogbeat)
* [Claude Desktop](https://claude.com/download)
* [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)

Ensure your Elastic Stack component versions match (I used version 9.5.5 for this project).

## Enabling and Starting Sysmon
placeholder text

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

## Extracting and Forwarding Claude Hooks

For this section, we'll be using the files `log-event.ps1` and `settings.json`.

Place `settings.json` into `%USERPROFILE%\.claude\` and place `log-event.ps1` into `%USERPROFILE%\.claude\hooks\` after creating the latter subfolder.

Note: The `\.claude\` directory will not exist until you have Claude Code perform an agentic action, so be sure to do so in order for the folder to initialize. Ask me how I know!

