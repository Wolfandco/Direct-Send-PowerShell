# Define the path to your file containing the list of email addresses
$emailListPath = "emailList.txt"

# Define the path to your HTML file for the email body
$bodyFilePath = "body.html"

# Load the email addresses from the file into an array
$emailAddresses = Get-Content -Path $emailListPath

# Read the HTML content and convert it to a string
$body = Get-Content -Path $bodyFilePath | Out-String

# Define the mail parameters
$smtpServer = "company-com.mail.protection.outlook.com"
$from = "First Last <first.last@company.com>"
$subject = "Subject Line Here"

# Iterate through each email address and send the message
foreach ($email in $emailAddresses) {
    Send-MailMessage -From $from -To $email -Subject $subject -Body $body -SmtpServer $smtpServer -BodyAsHtml
    Write-Host "Email sent to $email"
}
