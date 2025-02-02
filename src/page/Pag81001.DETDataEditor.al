page 81001 "DET Data Editor"
{

    CaptionML = DEU = 'Tabelleneditor', ENU = 'Data Editor';
    AdditionalSearchTermsML = DEU = 'LEC,Tabelle,Editor,Admin', ENU = 'data,editor,LEC,Admin';
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(SourceTableNoField; SourceTableNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Source Table No.';
                    CaptionML = DEU = 'Ursprungstabellennummer', ENU = 'Source Table No.';
                    ShowMandatory = true;
                    trigger OnValidate()
                    var
                        AllObjWithCaption: Record AllObjWithCaption;
                    begin
                        if SourceTableNo = 0 then begin
                            SourceTableName := '';
                            exit;
                        end;
                        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, SourceTableNo);
                        SourceTableName := AllObjWithCaption."Object Name";
                        CustomTableView := '';
                        SetNumberOfRecords('');
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObjWithCaption: Record AllObjWithCaption;
                        AllObjWithCaptionPage: Page "All Objects with Caption";
                    begin
                        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                        AllObjWithCaptionPage.SetTableView(AllObjWithCaption);
                        AllObjWithCaptionPage.LookupMode(true);
                        AllObjWithCaptionPage.Editable(false);
                        if AllObjWithCaptionPage.RunModal() <> Action::LookupOK then
                            exit;
                        AllObjWithCaptionPage.GetRecord(AllObjWithCaption);
                        SourceTableNo := AllObjWithCaption."Object ID";
                        SourceTableName := AllObjWithCaption."Object Name";
                        CustomTableView := '';
                        FieldFilter := '';
                        SetNumberOfRecords('');
                    end;
                }
                field(SourceTableNameField; SourceTableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Source Table Name';
                    CaptionML = DEU = 'Ursprungstabellenname', ENU = 'Source Table Name';
                    Editable = false;
                }
                field(CustomTableViewField; CustomTableView)
                {
                    ApplicationArea = All;
                    ToolTip = 'Set Initial Table Filter';
                    Caption = 'Table Filter';
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        SetCustomFilter();
                    end;
                }
                field(NumberOfRecordsField; NumberOfRecords)
                {
                    ApplicationArea = All;
                    ToolTip = 'Number Of Filtered Records';
                    CaptionML = DEU = 'Anzahl der Datensätze', ENU = 'Number Of Records';
                    Editable = false;
                }
                field(FieldFilter; FieldFilter)
                {
                    ApplicationArea = All;
                    ToolTip = 'Set Initial Field Filter';
                    CaptionML = DEU = 'Feldfilter', ENU = 'Field Filter';
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        SetFieldFilter();
                    end;
                }
                field(WithoutValidationField; WithoutValidation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Without Validation';
                    CaptionML = DEU = 'OHNE Validierung !!!!ACHTUNG!!!!', ENU = 'Without Validation (Warning!)';
                }
                field(ExcludeFlowFieldsField; ExcludeFlowFields)
                {
                    ApplicationArea = All;
                    ToolTip = 'Exclude FlowField''s from loading';
                    CaptionML = DEU = 'excludiere Flowfelder', ENU = 'Exclude FlowField''s';
                }
            }
        }

    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not (CloseAction in [CloseAction::OK, CloseAction::LookupOK]) then
            exit;
        if SourceTableNo <> 0 then
            RunDataEditorList();
    end;


    trigger OnInit()
    var
        UserPermissions: Codeunit "User Permissions";
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            Error('Only Super User can load this please contact Admins.');
    end;

    local procedure RunDataEditorList()
    var
        DataEditorBufferList: Page "DET Data Editor Buffer";
    begin
        DataEditorBufferList.LoadRecords(SourceTableNo, CustomTableView, FieldFilter, WithoutValidation, ExcludeFlowFields);
        DataEditorBufferList.Run();
    end;

    local procedure SetNumberOfRecords(TableView: Text)
    var
        RecRef: RecordRef;
    begin
        if SourceTableNo = 0 then
            exit;
        RecRef.Open(SourceTableNo);
        if TableView <> '' then
            RecRef.SetView(TableView);
        NumberOfRecords := RecRef.Count();
    end;

    local procedure SetCustomFilter()
    var
        CustomFilterPageBuilder: FilterPageBuilder;
    begin
        if SourceTableNo = 0 then
            exit;
        CustomFilterPageBuilder.AddTable(SourceTableName, SourceTableNo);
        if CustomTableView <> '' then
            CustomFilterPageBuilder.SetView(SourceTableName, CustomTableView);
        CustomFilterPageBuilder.RunModal();
        CustomTableView := CustomFilterPageBuilder.GetView(SourceTableName);
        SetNumberOfRecords(CustomTableView);
    end;

    local procedure SetFieldFilter()
    var
        SelectFields: Page "DET Select Fields";
    begin
        if SourceTableNo = 0 then
            exit;
        SelectFields.LoadFields(SourceTableNo, FieldFilter);
        SelectFields.LookupMode(true);
        SelectFields.Editable(true);
        if SelectFields.RunModal() <> Action::LookupOK then
            exit;
        FieldFilter := SelectFields.GetFieldIdFilter();
    end;

    var
        WithoutValidation: Boolean;
        ExcludeFlowFields: Boolean;
        SourceTableNo: Integer;
        NumberOfRecords: Integer;
        SourceTableName: Text;
        CustomTableView: Text;
        FieldFilter: Text;
}
