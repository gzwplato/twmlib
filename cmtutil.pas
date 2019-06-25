unit cmtutil;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, sqlite3ds;

type
  TCmtUtil = class(TObject)
    procedure createDB(filename: String);
    procedure close();
    procedure addTopic(bi, ci, fvi, tvi: Integer; rtf: String);
  private
    conn: TSQLite3Connection;
    tx: TSQLTransaction;
    procedure createDBSchema();
    procedure compactDB(filename: String);
  public

  end;

implementation

procedure TCmtUtil.addTopic(bi, ci, fvi, tvi: Integer; rtf: String);
var
  q: TSQLQuery;
begin
  q := TSQLQuery.Create(conn);
  q.SQLConnection := conn;
  q.Transaction := tx;
  q.SQL.Text := 'INSERT INTO bible_refs (bi, ci, fvi, tvi) VALUES (:bi, :ci, :fvi, :tvi);';
  q.Params.ParamByName('bi').AsInteger := bi;
  q.Params.ParamByName('ci').AsInteger := ci;
  q.Params.ParamByName('fvi').AsInteger := fvi;
  q.Params.ParamByName('tvi').AsInteger := tvi;
  q.ExecSQL;
  q.Close;
  q.Free;

  q := TSQLQuery.Create(conn);
  q.SQLConnection := conn;
  q.Transaction := tx;
  q.SQL.Text := 'INSERT INTO content (topic_id, data) select max(topic_id), :data from bible_refs;';
  q.Params.ParamByName('data').AsString := rtf;
  q.ExecSQL;
  q.Close;
  q.Free;

  //conn.ExecuteDirect('INSERT INTO content_search (topic_id) select max(topic_id) from bible_refs;');
end;

procedure TCmtUtil.createDB(filename: String);
var
  title: String;
  exists: Boolean;
begin
  exists := FileExists(filename);
  conn := TSQLite3Connection.Create(nil);
  tx := TSQLTransaction.Create(conn);
  conn.Transaction := tx;
  conn.DatabaseName := filename;
  tx.StartTransaction;

  if (not exists) then
  begin
    createDBSchema();
    title := ExtractFileName(filename);
    title := title.Substring(0, title.LastIndexOf('.'));
    conn.ExecuteDirect('INSERT INTO config(name,value) VALUES (''title'','''+title+''')');
    conn.ExecuteDirect('INSERT INTO config(name,value) VALUES (''abbrev'','''+title+''')');
    conn.ExecuteDirect('INSERT INTO config(name,value) VALUES (''type'',''2'')');
    conn.ExecuteDirect('INSERT INTO config(name,value) VALUES (''schema.version'',''1'')');
    conn.ExecuteDirect('INSERT INTO config(name,value) VALUES (''search.index.ver'',''4'')');
    conn.ExecuteDirect('INSERT INTO config(name,value) VALUES (''user'',''1'')');
    conn.ExecuteDirect('INSERT INTO config(name,value) VALUES (''content.type'',''rtf'')');
  end;
end;

procedure TCmtUtil.close();
begin
  tx.Commit;
  tx.Free;
  conn.Free;
end;

procedure TCmtUtil.compactDB(filename: String);
var
  tmpDataset: TSqlite3Dataset;
begin
  tmpDataset := TSqlite3Dataset.Create(nil);
  tmpDataset.FileName := filename;
  tmpDataset.ExecSQL('VACUUM;');
  tmpDataset.Free;
end;

procedure TCmtUtil.createDBSchema();
begin
  conn.ExecuteDirect('CREATE TABLE config(name text, value text);');
  conn.ExecuteDirect('CREATE TABLE content(topic_id integer primary key, data BLOB, data2 blob);');
  //conn.ExecuteDirect('CREATE TABLE content_search(topic_id integer primary key, data blob);');
  conn.ExecuteDirect('CREATE TABLE bible_refs(topic_id integer primary key AUTOINCREMENT, bi integer, ci integer, fvi integer, tvi integer, content_type text);');
  conn.ExecuteDirect('CREATE INDEX idx_bible_refs on bible_refs(bi, ci, fvi, tvi);');
  conn.ExecuteDirect('CREATE INDEX idx_bible_refs_bi_ci on bible_refs(bi, ci);');
end;

end.

