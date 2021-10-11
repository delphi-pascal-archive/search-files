unit Search;

interface

uses
  Windows, Classes;

function SearchInFolder(folder, mask: String; flags: DWORD;
                        names: TStrings; addpath: Boolean = False): Boolean;
function SearchInTree(folder, mask: String; flags: DWORD;
                      names: TStrings; addpath: Boolean = False): Boolean;

implementation

//������� ���������� True, ���� �������� (attrs) ����� ��� �����
//������������� ������ ������ (flags)
//��������� ��������� �������� (����������� ����� � ��������, �������
//������� ��������, ���������� �� ������� � ��� ������ ��������������
//���������, ������� �� ������ ��� ������).
//��� ���������� ������� �������� ����� ��������
//MatchAttrs := (flags and attrs) = flags; ��
//MatchAttrs := (flags = attrs);
function MatchAttrs(flags, attrs: DWORD): Boolean;
begin
  MatchAttrs := (flags and attrs) = flags;
end;

//����� �� ����� � ��������� � �������� ����� (���� ������ ���� ���� ����
//��� �������, �� ������������ True).
//������ names ����������� ������� ��������� ������ � �����
function SearchInFolder(folder, mask: String; flags: DWORD;
                        names: TStrings; addpath: Boolean = False): Boolean;
var
  hSearch: THandle;
  FindData: WIN32_FIND_DATA;
  strSearchPath: String;
  bRes: Boolean; //���� ����� True, �� ����� ���� �� ���� ���� ��� �������
begin
  strSearchPath := folder + '\' + mask;
  bRes := False;
  //�������� �����
  hSearch := FindFirstFile(PAnsiChar(strSearchPath), FindData);
  if (hSearch <> INVALID_HANDLE_VALUE) then
  begin
    //���� ��� ������� �������� (���������� � ������ �������� ���
    //�������� � FindData �������� FindFirstFile)
    repeat
      if (String(FindData.cFileName) <> '..') and
         (String(FindData.cFileName) <> '.') then //���������� . � ..
      begin
        if MatchAttrs(flags, FindData.dwFileAttributes) then
        begin
          //����� ���������� ������
          if addpath then
            names.Add(folder + '\' + FindData.cFileName)
          else
            names.Add(FindData.cFileName);
          bRes := True;
        end;
      end;
    until FindNextFile(hSearch, FindData) = FALSE;
    //����������� �����
    FindClose(hSearch);
  end;
  SearchInFolder := bRes;
end;


//������� ������ � ������ ��������� � �������� �������� ��������� (folder)
//� ������ ������������ ������ ���� ��������� ������ � �����
function SearchInTree(folder, mask: String; flags: DWORD;
                      names: TStrings; addpath: Boolean = False): Boolean;
var
  hSearch: THandle;
  FindData: WIN32_FIND_DATA;
  bRes: Boolean; //���� ����� True, �� ����� ���� �� ���� ���� ��� �������
begin

  //������������ ����� � ������� �����
  bRes := SearchInFolder(folder, mask, flags, names, addpath);

  //��������� ����� � ������ �� ������������
  hSearch := FindFirstFile(PAnsiChar(folder + '\*'), FindData);
  if (hSearch <> INVALID_HANDLE_VALUE) then
  begin
    repeat
      if (String(FindData.cFileName) <> '..') and
         (String(FindData.cFileName) <> '.') then //���������� . � ..
      begin
        if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0)
        then
          //����� ���������� - �������� � ��� �����
          if SearchInTree(folder + '\' + String(FindData.cFileName),
                          mask, flags, names, addpath)
          then
            bRes := True;
      end;
    until FindNextFile(hSearch, FindData) = FALSE;
    FindClose(hSearch);
  end;
  SearchInTree := bRes;
end;

end.
