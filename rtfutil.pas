unit rtfutil;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function createTopicLink(bookid, topicid, topicname: String): String;
function createBookHeader(bookname: String): String;
function createTopicHeader(): String;
function createTopicFooter(): String;

implementation

function createTopicLink(bookid, topicid, topicname: String): String;
begin
  Result := '{{\field{\*\fldinst HYPERLINK "tw://bk.'
            + bookid + '?tid='+topicid+'&popup=1"}{\fldrslt \plain \f1\fs20\cf2 - '
            + topicname + '.}}\par}';
end;

function createBookHeader(bookname: String): String;
begin
  Result := '{'+bookname+'}\par';
end;

function createTopicHeader(): String;
begin
  Result := '{\rtf1\ansi\ansicpg0\uc0\deff0\deflang0\deflangfe0{\colortbl;\red0\green0\blue0;\red0\green0\blue255;\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;\red128\green128\blue128;\red192\green192\blue192;}\pard\li200\fi-200\plain ';
end;

function createTopicFooter(): String;
begin
  Result := '}'
end;

end.

