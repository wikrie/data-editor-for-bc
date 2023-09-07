page 81009 "RunObject List"
{
    CaptionML = DEU = 'RunObject', ENU = 'RunObject List';
    Editable = false;
    PageType = List;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Filter';
    UsageCategory = Administration;
    SourceTable = AllObjWithCaption;
    SourceTableView = where("Object Type" = filter(= Table | Page | Query | Report | XMLport | Codeunit));
    layout
    {
        area(Content)
        {
            repeater(TableList)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                }
                field("Object Subtype"; Rec."Object Subtype")
                {
                    ApplicationArea = All;
                }
                field("App Name"; GetAppName(Rec."App Package ID"))
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Run Selected Object")
            {
                CaptionML = DEU = 'ausgewähltes Object ausführen', ENU = 'Run Selected Object';
                ApplicationArea = All;
                Image = ExecuteBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                trigger OnAction()
                begin
                    RunObject();
                end;
            }
            action("Show All Tables")
            {
                CaptionML = DEU = 'Alle Tabellen anzeigen', ENU = 'Show All Tables';
                ApplicationArea = All;
                Image = Filter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    FilterObjects(Rec."Object Type"::Table);
                end;
            }
            action("Show All Pages")
            {
                CaptionML = DEU = 'alle Seiten anzeigen', ENU = 'Show All Pages';
                ApplicationArea = All;
                Image = Filter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    FilterObjects(Rec."Object Type"::Page);
                end;
            }
            action("Show All Reports")
            {
                CaptionML = DEU = 'alle Berichte anzeigen', ENU = 'Show All Reports';
                ApplicationArea = All;
                Image = Filter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    FilterObjects(Rec."Object Type"::Report);
                end;
            }
            action("Show All Queries")
            {
                CaptionML = DEU = 'alle Abfragen anzeigen', ENU = 'Show All Queries';
                ApplicationArea = All;
                Image = Filter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    FilterObjects(Rec."Object Type"::Query);
                end;
            }
            action("Show All XMLports")
            {
                CaptionML = DEU = 'alle XMLPorts anzeigen', ENU = 'Show All XMLports';
                ApplicationArea = All;
                Image = Filter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    FilterObjects(Rec."Object Type"::XMLport);
                end;
            }
            action("Show All Codeunits")
            {
                CaptionML = DEU = 'alle Codeunits anzeigen', ENU = 'Show All Codeunits';
                ApplicationArea = All;
                Image = Filter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    FilterObjects(Rec."Object Type"::Codeunit);
                end;
            }
            action("Reset Filter")
            {
                CaptionML = DEU = 'Filter zurück setzen', ENU = 'Reset Filter';
                ApplicationArea = All;
                Image = ResetStatus;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    ResetFilter();
                end;
            }
        }
    }
    local procedure GetAppName(var AppPackageID: Guid): Text[250]
    var
        NavInstalledApp: Record "NAV App Installed App";
    begin
        NavInstalledApp.Reset();
        NavInstalledApp.SetRange("Package ID", AppPackageID);
        if NavInstalledApp.FindFirst() then
            exit(NavInstalledApp.Name);
    end;

    local procedure RunObject()
    begin
        case Rec."Object Type" of
            Rec."Object Type"::Table:
                Hyperlink(GetUrl(ClientType::Current, CompanyName, ObjectType::Table, Rec."Object ID"));
            Rec."Object Type"::Query:
                Hyperlink(GetUrl(ClientType::Current, CompanyName, ObjectType::Query, Rec."Object ID"));
            Rec."Object Type"::Page:
                PAGE.RUN(Rec."Object ID");
            Rec."Object Type"::Report:
                REPORT.RUN(Rec."Object ID");
            Rec."Object Type"::XMLport:
                XMLPORT.RUN(Rec."Object ID");
        end;
    end;

    local procedure ResetFilter()
    begin
        Rec.Reset();
        Rec.SetFilter("Object Type", '%1|%2|%3|%4|%5', Rec."Object Type"::Table, Rec."Object Type"::Page, Rec."Object Type"::Report, Rec."Object Type"::Query, Rec."Object Type"::XMLport);
        Rec.FindFirst();
    end;

    local procedure FilterObjects(ObjectType: Integer)
    begin
        Rec.Reset();
        Rec.SetRange("Object Type", ObjectType);
        Rec.FindFirst();
    end;
}