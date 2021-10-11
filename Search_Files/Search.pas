unit Search;

interface

uses
  Windows, Classes;

function SearchInFolder(folder, mask: String; flags: DWORD;
                        names: TStrings; addpath: Boolean = False): Boolean;
function SearchInTree(folder, mask: String; flags: DWORD;
                      names: TStrings; addpath: Boolean = False): Boolean;

implementation

//Функция возвращает True, если атрибуты (attrs) файла или папки
//соответствуют режиму поиска (flags)
//Реализует нестрогую проверку (принимаются файлы и каталоги, имеющие
//искомые атрибуты, независимо от наличия у них других дополнительных
//атрибутов, которые не заданы при поиске).
//Для реализации строгой проверки можно изменить
//MatchAttrs := (flags and attrs) = flags; на
//MatchAttrs := (flags = attrs);
function MatchAttrs(flags, attrs: DWORD): Boolean;
begin
  MatchAttrs := (flags and attrs) = flags;
end;

//Поиск по маске и атрибутам в заданной папке (если найден хоть один файл
//или каталог, то возвращается True).
//Список names заполняется именами найденных файлов и папок
function SearchInFolder(folder, mask: String; flags: DWORD;
                        names: TStrings; addpath: Boolean = False): Boolean;
var
  hSearch: THandle;
  FindData: WIN32_FIND_DATA;
  strSearchPath: String;
  bRes: Boolean; //Если равен True, то нашли хотя бы один файл или каталог
begin
  strSearchPath := folder + '\' + mask;
  bRes := False;
  //Начинаем поиск
  hSearch := FindFirstFile(PAnsiChar(strSearchPath), FindData);
  if (hSearch <> INVALID_HANDLE_VALUE) then
  begin
    //Ищем все похожие элементы (информация о первом элементе уже
    //записана в FindData функцией FindFirstFile)
    repeat
      if (String(FindData.cFileName) <> '..') and
         (String(FindData.cFileName) <> '.') then //Пропускаем . и ..
      begin
        if MatchAttrs(flags, FindData.dwFileAttributes) then
        begin
          //Нашли подходящий объект
          if addpath then
            names.Add(folder + '\' + FindData.cFileName)
          else
            names.Add(FindData.cFileName);
          bRes := True;
        end;
      end;
    until FindNextFile(hSearch, FindData) = FALSE;
    //Заканчиваем поиск
    FindClose(hSearch);
  end;
  SearchInFolder := bRes;
end;


//Функция поиска в дереве каталогов с заданным корневым каталогом (folder)
//В список записываются полные пути найденных файлов и папок
function SearchInTree(folder, mask: String; flags: DWORD;
                      names: TStrings; addpath: Boolean = False): Boolean;
var
  hSearch: THandle;
  FindData: WIN32_FIND_DATA;
  bRes: Boolean; //Если равен True, то нашли хотя бы один файл или каталог
begin

  //Осуществляем поиск в текущей папке
  bRes := SearchInFolder(folder, mask, flags, names, addpath);

  //Продолжим поиск в каждом из подкаталогов
  hSearch := FindFirstFile(PAnsiChar(folder + '\*'), FindData);
  if (hSearch <> INVALID_HANDLE_VALUE) then
  begin
    repeat
      if (String(FindData.cFileName) <> '..') and
         (String(FindData.cFileName) <> '.') then //Пропускаем . и ..
      begin
        if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0)
        then
          //Нашли подкаталог - выполним в нем поиск
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
