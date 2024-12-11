namespace AardvarkLabs;

using System.Apps.AppSource;
using System.Utilities;
pageextension 50000 "ARD_AppSource Product List" extends "AppSource Product List"
{
    layout
    {
        // Add changes to page layout here
        addafter(DisplayName)
        {
            field(AppSourceLink; AppSourceLink)
            {
                ExtendedDatatype = url;
                ApplicationArea = all;
                Caption = 'AppSource GDAP Link';
                ToolTip = 'AppSource GDAP Link';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter(OpenAppSource)
        {
            action(AppSourceUrl)
            {
                Caption = 'Open AppSource Url';
                ToolTip = 'Open AppSource Url';
                Image = Link;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    AppSourceLink := GenerateLink();
                    System.Hyperlink(AppSourceLink);
                end;
            }
        }
        addafter(Open_Promoted)
        {
            actionref(AppSourcePromo; AppSourceUrl)
            {
            }
        }
    }

    var
        AppSourceLink: text;

    trigger OnAfterGetRecord()
    var
    begin
        AppSourceLink := GenerateLink();
    end;

    // This procedure generates a URL link for a Business Central application page.
    // The generated link includes the tenant ID and a filter for the application ID.
    //
    // Returns:
    //   Text: The generated URL link.
    //
    // Example:
    //   https://businesscentral.dynamics.com/TenantID/?noSignUpCheck=1&filter='ID'%20IS%20'AppID'&page=2503
    //
    // Variables:
    //   AppID: Text - The application ID after removing curly braces.
    //   AppURL: Text - The generated URL link.
    procedure GenerateLink(): Text
    var
        AppID: Text;
        AppURL: Text; //https://businesscentral.dynamics.com/TenantID/?noSignUpCheck=1&filter=%27ID%27%20IS%20%27AppID%27&page=2503
    begin

        AppId := DelChr(rec.AppID, '<>', '{}');
        AppURL := 'https://businesscentral.dynamics.com/' + GetTenantID() + '/?noSignUpCheck=1&filter=%27ID%27%20IS%20%27' + AppID + '%27&page=2503';
        exit(CopyStr(AppURL, 1, 2048));
    end;

    /// <summary>
    /// Retrieves the Tenant ID from the current web client URL.
    /// </summary>
    /// <remarks>
    /// This method uses a regular expression to find and extract a GUID (Tenant ID) from the URL.
    /// </remarks>
    /// <returns>
    /// A text value representing the Tenant ID if found; otherwise, an empty string.
    /// </returns>
    /// <example>
    /// <code>
    /// var
    ///     TenantId: Text;
    /// begin
    ///     TenantId := GetTenantID();
    /// end;
    /// </code>
    /// </example>
    procedure GetTenantID(): Text
    var
        TempMatches: Record Matches temporary;
        Regex: CodeUnit Regex;
        Pattern: Text;
        TenantId: Text;
    begin
        Pattern := '[({]?[a-fA-F0-9]{8}[-]?([a-fA-F0-9]{4}[-]?){3}[a-fA-F0-9]{12}[})]?';
        Regex.Match(GetUrl(ClientType::Web), Pattern, TempMatches);

        if TempMatches.FINDFIRST() then
            TenantId := TempMatches.ReadValue();

        exit(TenantId);
    end;
}