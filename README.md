# Direct-Send-PowerShell
Direct Send PowerShell Code to send in an Entra Cloud Shell

This code will loop through the emails within the emailList.txt file and use the "Send-MailMessage" cmdlet to send emails using the Direct Send methodology.

## Usage:

```
1. Open Entra Cloud Shell
2. git clone https://github.com/Wolfandco/Direct-Send-PowerShell
3. Create a file called "emailList.txt"
4.
  4a. Create a file called "body.html"
  4b. Change the "body.html" line in the directSend.ps1
5. Add HTML code to HTML file
6. Add emails to "emailList.txt"
7. Add FROM emails to "fromEmails.txt"
8. Import-Module DirectSend.ps1
9. Invoke-DirectSend -SMTPServer company-com.mail.protection.outlook.com -FromFile ./fromEmails.txt -ToFile ./emailList.txt -Body ./body.html -Subject "Test Subject" -Priorty High
```

## Resources:

- [The Call Is Coming From Inside the House: Microsoft Direct Send and Why You Need to Mitigate Now](https://www.wolfandco.com/resources/blog/call-coming-inside-house-microsoft-direct-send-why-you-need-mitigate/)
- [Microsoft Direct Send – Phishing Abuse Primitive](https://www.jumpsec.com/guides/microsoft-direct-send-phishing-abuse-primitive/)
- [Spoofing Microsoft 365 Like It’s 1995](https://www.blackhillsinfosec.com/spoofing-microsoft-365-like-its-1995/)

## Inspiration + Added Functionality + ShoutOut

- [Rvrsh3ll FindIngressEmail](https://github.com/rvrsh3ll/FindIngressEmail)
