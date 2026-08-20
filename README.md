# Artificial Intelligence

I downloaded LM Studio, where I created a virtual AI helper.

I connected my virtual AI chat to talk to my claude code. where it would pull directly from it's own intelligence instead of surfing the web

# DataBase

I downloaded DBeaver, MySQL, and PostGreSQL

I connected the MySQL and PostGreSQL to my DBeaver where they can now be accessed

## humanlayer

[https://github.com/humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)  
[https://www.humanlayer.dev/](https://www.humanlayer.dev/)  
In order to start the process of workflow, you need to run a setup-humanlayer.sh in project directory

## AI Worflow = humanlayer

The workflow for this is 4 steps

1. Research    /research_codebase 'what information you want to specify'
2. Plan        /create_plan  @./thoughts/shared/research/*  'what you want it to do'
3. Implement      /implement_plan @./thoughts/shared/plans/* phase #
4. Validate Plan  /validate_plan @./thoughts/shared/plans/*

## Updated AI Workflow: QRSPI

The updated workflow is now 8ish steps

1. Questions
2. Research
3. Design
4. Structure
5. Plan
6. Worktree
7. Implement
8. Validate

need to run setup-humanlayer in wsl

runs the humanlayer command

```
wsl bash ../../setup-humanlayer.sh
```

When your claude Context reaches around 60% you want to put the context you have gained into an md file, reset claude, then make the new claude read the md file to start where you left off.

For this web app I just created via giving claude inputs and information on how I wanted this app to be made. I then checked what the ai was doing to validate if it was a valid change or if it deleted or did stuff that was unnecessary. Lastly I tested the web app to see if it worked well.

Go step by step. Claude will give you a multi phase process on building the web app, so go implement phase 1, then phase 2, and so on till it is done.

On the web app, if you ever want to test vulnerabilities go to this route

```
/manage/demo/sqli/vulnerable/
```

install caveman into claude  
irm [https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1](https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1) | iex

if that doesnt work, install node.js  
 winget install OpenJS.NodeJS.LTS
