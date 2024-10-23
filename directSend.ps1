function Invoke-DirectSend {
    <#
        .SYNOPSIS
        Check mail filters from random domains.

        .DESCRIPTION
        A script to test the efficacy of SPAM filters.

        .PARAMETER SMTPServer
        Target SMTP server.

        .PARAMETER Subject
        Specifies the subject of the email.

        .PARAMETER BodyFile
        Specify an HTML formatted file for the email body.

        .PARAMETER FromFile
        Specify a file with a single or multiple From email addresses.

        .PARAMETER ToFile
        Specify a file with a list of To email addresses.

        .PARAMETER EmailSmtpUser
        Specify an SMTP user.

        .PARAMETER EmailSmtpPass
        Specify an SMTP password.

        .PARAMETER BodyEncoding
        Specify the Body Encoding.

        .PARAMETER SubjectEncoding
        Specify the Subject Encoding.

        .PARAMETER HeadersEncoding
        Specify the Body Headers Encoding.

        .PARAMETER BodyTransferEncoding
        Specify the Body Transfer Encoding.

        .PARAMETER Delay
        Specify the delay between sending emails.

        .PARAMETER RetryDelay
        Specify the delay between rate-limited emails.

        .EXAMPLE
        C:\PS> Invoke-DirectSend -SMTPServer smtp.mailgun.org -Subject "Test Email" -BodyFile ./Body.html -FromFile ./fromEmails.txt -ToFile ./toEmails.txt -EmailSmtpUser "user" -EmailSmtpPass "pass"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$SMTPServer,

        [Parameter(Mandatory = $true)]
        [String]$Subject,

        [Parameter(Mandatory = $true)]
        [String]$BodyFile = "body.html",

        [Parameter(Mandatory = $true)]
        [String]$FromFile = "fromEmails.txt",

        [Parameter(Mandatory = $true)]
        [String]$ToFile = "emailList.txt",

        [Parameter(Mandatory = $false)]
        [String]$EmailSmtpUser,

        [Parameter(Mandatory = $false)]
        [String]$EmailSmtpPass,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Normal", "High", "Low")]
        [String]$Priority = "Normal",

        [Parameter(Mandatory = $false)]
        [ValidateSet("ascii", "bigendianutf32", "unicode", "utf8", "utf8NoBOM", "bigendianunicode", "oem", "utf7", "utf8BOM", "utf32")]
        [String]$BodyEncoding = "utf8",

        [Parameter(Mandatory = $false)]
        [ValidateSet("ascii", "bigendianutf32", "unicode", "utf8", "utf8NoBOM", "bigendianunicode", "oem", "utf7", "utf8BOM", "utf32")]
        [String]$SubjectEncoding = "utf8",

        [Parameter(Mandatory = $false)]
        [ValidateSet("ascii", "bigendianutf32", "unicode", "utf8", "utf8NoBOM", "bigendianunicode", "oem", "utf7", "utf8BOM", "utf32")]
        [String]$HeadersEncoding = "utf8",

        [Parameter(Mandatory = $false)]
        [ValidateSet("QuotedPrintable", "Base64", "SevenBit", "EightBit", "Unknown")]
        [String]$BodyTransferEncoding = "QuotedPrintable",

        [Parameter(Mandatory = $false)]
        [Int]$Delay = 10,

        [Parameter(Mandatory = $false)]
        [Int]$RetryDelay = 31
    )

    # Load email body, From emails, and To emails
    $EmailBody = Get-Content $BodyFile | Out-String
    $FromEmails = Get-Content $FromFile
    $ToEmails = Get-Content $ToFile

    foreach ($FromAddress in $FromEmails) {
        foreach ($ToEmail in $ToEmails) {
            try {
                # Create the mail message
                $m = New-Object System.Net.Mail.MailMessage
                $m.IsBodyHtml = $true
                $m.Body = $EmailBody
                $m.Subject = $Subject
                $m.From = $FromAddress
                $m.Sender = $FromAddress
                $m.ReplyToList.Add($FromAddress)

                # Add single recipient
                $m.To.Add($ToEmail)

                # Set priority
                if ($Priority) {
                    $m.Priority = [System.Net.Mail.MailPriority]::$Priority
                }

                # Set encodings
                if ($BodyEncoding) {
                    $m.BodyEncoding = [System.Text.Encoding]::$BodyEncoding
                }
                if ($SubjectEncoding) {
                    $m.SubjectEncoding = [System.Text.Encoding]::$SubjectEncoding
                }
                if ($HeadersEncoding) {
                    $m.HeadersEncoding = [System.Text.Encoding]::$HeadersEncoding
                }
                if ($BodyTransferEncoding) {
                    $m.BodyTransferEncoding = [System.Net.Mime.TransferEncoding]::$BodyTransferEncoding
                }

                # Add custom headers if provided
                if ($Headers) {
                    foreach ($key in $Headers.Keys) {
                        $m.Headers.Add($key, $Headers[$key])
                    }
                }

                # Set Return-Path header
                $m.Headers.Add('Return-Path', $FromAddress)

                # Set up SMTP client
                $smtp = New-Object Net.Mail.SmtpClient($SMTPServer)
                if ($EmailSmtpUser -and $EmailSmtpPass) {
                    $smtp.Credentials = New-Object System.Net.NetworkCredential($EmailSmtpUser, $EmailSmtpPass)
                } elseif ($EmailSmtpUser -or $EmailSmtpPass) {
                    Write-Error "Both EmailSmtpUser and EmailSmtpPass must be specified if one is provided."
                    return
                }

                # Send the email
                Write-Verbose "Sending email from $FromAddress to $ToEmail with priority $Priority ..."
                $smtp.Send($m)
                Write-Host "Email sent from $FromAddress to $ToEmail successfully."

                # Delay between sends
                Start-Sleep -Seconds $Delay
            }
            catch {
                Write-Warning "Error sending email from $FromAddress to ${ToEmail}: $($_.Exception.Message)"
                Start-Sleep -Seconds $RetryDelay
                continue
            }
        }
    }
}
