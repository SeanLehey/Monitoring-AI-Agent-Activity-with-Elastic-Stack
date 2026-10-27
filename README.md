# Monitoring AI Agent Activity with Elastic Stack
_Project in Progress_

> [!NOTE]
> See my [AI ethics statement](https://github.com/SeanLehey/Personal-AI-Ethics-Statement) for how I use, and don't use, AI for certain tasks.

## Project Overview
As more companies provision licenses for AI tools, and as those tools become more autonomous, I believe it's prudent to learn how to closely monitor agentic activity within enterprise environments. This project is intended to demonstrate what key activity to look out for, and how to pipe this data into an analytics platform of your choice (in this case, Elastic Stack). We will be examining Sysmon activity attributed to the Claude Desktop executable, along with Claude's [hooks](https://code.claude.com/docs/en/hooks) for more granular activity information.

## Resources
* [Elasticsearch](https://www.elastic.co/downloads/elasticsearch)
* [Kibana](https://www.elastic.co/downloads/kibana)
* [Filebeat](https://www.elastic.co/downloads/beats/filebeat)
* [Winlogbeat](https://www.elastic.co/downloads/beats/winlogbeat)
* [Claude Desktop](https://claude.com/download)
* [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)

Ensure your Elastic Stack component versions match (I used 9.5.5 for this project).

## Installing ELK
Start by downloading the four ELK components above in any order. Then install as follows:

Extract the contents of `elasticsearch-9.5.5-windows-x86_64` to a location of your choice - in this case, we will extract to `C:\ELK\`.

<img width="1414" height="302" alt="image" src="https://github.com/user-attachments/assets/91adfd56-66aa-4adb-935d-1b88fd51440b" />

Then open a terminal, run `cd C:\ELK\elasticsearch-9.5.5`, and type `.\bin\elasticsearch.bat`. This will provide you with a password for the `elastic` user as well as an enrollment token you'll need to save for when we launch the web application.

<img width="2512" height="918" alt="image" src="https://github.com/user-attachments/assets/72de2b3a-fe74-423a-a0b4-76dec533f9ca" />
