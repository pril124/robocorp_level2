*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.Archive
Library             PDFGenerator.py
Library             RPA.Dialogs
Library             OperatingSystem
Library             RPA.Robocloud.Secrets


*** Variables ***
${RETRIES}=     5x
${INTERVAL}=    1s


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${url}=    Input URL
    Log    ${url}
    Download orders    ${url}
    Open the robot order website
    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Click Element If Visible    //button[contains(text(), 'OK')]
        Wait Until Keyword Succeeds    ${RETRIES}    ${INTERVAL}    Fill and submit form    ${order}
        Generate PDF    ${order}
        Order another robot
    END
    Zip files
    [Teardown]    Close the browser


*** Keywords ***
Open the robot order website
    ${secret}=    Get Secret    robotsparebin
    Open Available Browser    ${secret}[url]

Download orders
    [Arguments]    ${url}
    Download    ${url}    overwrite=True

Fill and submit form
    [Arguments]    ${order}
    ${present}=    Run Keyword And Return Status    Element Should Be Visible    //div[@class="alert alert-danger"]
    IF    ${present}    Reload Page
    Click Element If Visible    //button[contains(text(), 'OK')]
    Select From List By Value    //select[@id='head']    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    //input[@class="form-control"][@type="number"]    ${order}[Legs]
    Input Text    //input[@id='address']    ${order}[Address]
    Click Button    Preview
    Click Button    Order
    Assert order successful

Generate PDF
    [Arguments]    ${order}
    Wait Until Element Is Visible    //div[@id='receipt']
    ${receipt_html}=    Get Element Attribute    //div[@id='receipt']    outerHTML
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}image${order}[Order number].png
    Get Pdf    ${order}[Order number]    ${receipt_html}    ${OUTPUT_DIR}${/}image${order}[Order number].png

Zip files
    Archive Folder With ZIP
    ...    ${OUTPUT_DIR}
    ...    ${OUTPUT_DIR}${/}orders.zip
    ...    recursive=True
    ...    include=*.pdf
    ...    exclude=/.*

Order another robot
    Click Button    Order another robot

Assert order successful
    Element Attribute Value Should Be    //div[@id='receipt']    class    alert alert-success

Assert order error
    Element Attribute Value Should Be    //div    class    alert alert-danger

Close the browser
    Close Browser

Input URL
    Add heading    Input CSV file URL
    Add text input    url    label=url
    ${result}=    Run dialog
    RETURN    ${result.url}
