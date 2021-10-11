unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Search, ExtCtrls, Mask, sMaskEdit, sCustomComboEdit,
  sTooledit, sEdit, sSkinManager, sLabel, sHintManager;

type
  TfMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    lstFiles: TListBox;
    Panel1: TPanel;
    txtFolder: TsDirectoryEdit;
    GroupBox2: TGroupBox;
    chkDirs: TCheckBox;
    chkArchive: TCheckBox;
    chkHidden: TCheckBox;
    chkSystem: TCheckBox;
    chkReadOnly: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    txtMask: TsEdit;
    lblFound: TLabel;
    sSkinManager1: TsSkinManager;
    Button3: TButton;
    sLabelFX1: TsLabelFX;
    sHintManager1: TsHintManager;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure lstFilesDblClick(Sender: TObject);
  private
    { Private declarations }
    function MySearch(InTree: boolean): boolean;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation
uses
  ShellAPI;

{$R *.dfm}

//Запуск поиска файла в заданной папке
procedure TfMain.Button1Click(Sender: TObject);
begin
  MySearch(False);
end;

//Запуск рекурсивного поиска файла в дереве каталогов
procedure TfMain.Button2Click(Sender: TObject);
begin
  MySearch(True);
end;

procedure TfMain.Button3Click(Sender: TObject);
begin
  Close;
end;

function TfMain.MySearch(InTree: boolean): boolean;
var
  flags: DWORD;
begin
  Result := False;
  Application.ProcessMessages;
  //Формируем набор атрибутов (по установленным флажкам на форме)
  flags := 0;
  if (chkDirs.Checked) then flags := flags or FILE_ATTRIBUTE_DIRECTORY;
  if (chkHidden.Checked) then flags := flags or FILE_ATTRIBUTE_HIDDEN;
  if (chkSystem.Checked) then flags := flags or FILE_ATTRIBUTE_SYSTEM;
  if (chkReadOnly.Checked) then flags := flags or FILE_ATTRIBUTE_READONLY;
  if (chkArchive.Checked) then flags := flags or FILE_ATTRIBUTE_ARCHIVE;

  lblFound.Caption := 'Пожалуйста,подождите: поиск...';
  lstFiles.Clear;
  Refresh;
  //Поиск (файлы записываются прямо в список на форме)
  if InTree then
  Result := SearchInTree(txtFolder.Text, txtMask.Text, flags,
            lstFiles.Items, True)
  else
  Result := SearchInFolder(txtFolder.Text, txtMask.Text, flags,
            lstFiles.Items);
  if not Result then
    lblFound.Caption := 'Поиск не дал результатов'
  else
    lblFound.Caption := 'Найдено объектов: ' + IntToStr(lstFiles.Count);
end;

procedure TfMain.lstFilesDblClick(Sender: TObject);
begin
  try
   winexec(Pchar('explorer.exe ' + lstFiles.Items[lstFiles.ItemIndex]),sw_Show);
    (*
    ShellExecute(Self.Handle,'open', 'cmd', 'explorer.exe',
    PChar(lstFiles.Items[lstFiles.ItemIndex])),  SW_NORMAL);
     *)
  except
    ShowMessage('Не могу открыть данный файл :(');
  end;
end;

end.
