page 50100 "Item Setup Wizard"
{

    Caption = 'Item Setup Wizard';
    PageType = NavigatePage;
    SourceTable = "Company Information";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {

            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to Company Setup")
                {
                    Caption = 'Welcome to Company Setup';
                    InstructionalText = 'To prepare Dynamics 365 Business Central ...';
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to specify basic company info.';
                }
            }
            group(Step2)
            {
                Caption = 'Specify your company'' address information and logo.';
                InstructionalText = 'This is used in invoices and other documents...';
                Visible = Step2Visible;

                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Name';
                    NotBlank = true;
                    ShowMandatory = true;
                }
                field(Address; Address)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(City; City)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    TableRelation = "Country/Region".Code;
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
            }
            group(Step3)
            {
                Visible = Step3Visible;

            }

            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStd; MediaResourcesStd."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStd: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,Step2,Finish;

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStd.Get('AssistedSetup-NoText-400px.png',
           Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png',
           Format(CurrentClientType()))
        then
            if MediaResourcesStd.Get(MediaRepositoryStd."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Finish:
                ShowStep3();
        end;
    end;

    local procedure ShowStep1();
    begin
        Step1Visible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep2();
    begin
        Step2Visible := true;
    end;

    local procedure ShowStep3();
    begin
        Step3Visible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
    end;

    local procedure FinishAction();
    begin
        StoreRecordVar();
        CurrPage.Close();
    end;

    local procedure StoreRecordVar();
    var
        RecordVar: Record "Company Information";
    begin
        if not RecordVar.Get() then begin
            RecordVar.Init();
            RecordVar.Insert();
        end;

        RecordVar.TransferFields(Rec, false);
        RecordVar.Modify(true);
    end;
}
