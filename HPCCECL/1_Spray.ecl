IMPORT STD;

lzip:= '10.173.147.1';
SrcPathPrefix := '/var/lib/HPCCSystems/mydropzone/';
SrcPathFileDir := 'Incoming-FWLogs/Incoming/';
SrcPath := SrcPathPrefix + SrcPathFileDir ;
today := (STRING) (STD.Date.Today());
DestFileName := '~hpccsystems::covid19::file::raw::johnhopkins::incoming_'+ today + '.csv';


serv := 'server=http://10.173.147.1:8010 ';
srcip := 'srcip='+lzip+' ';
over := 'overwrite=1 ';
repl := 'replicate=1 ';
dstcluster := 'dstcluster=mythor ';
maxRecordSize := 'maxrecordsize=1000000 '; 
action  := 'action=spray ';
dstip   := 'dstip='+lzip+' ';
dstfile := 'dstname=' + DestFileName + ' ';
srcname := 'srcfile='+SrcPath+'* ';
format := 'format=csv ';
nosplit := 'nosplit=1 ';
cmd := serv + over + repl + action + srcip + dstfile + dstcluster + srcname + format  + nosplit;
output(cmd); 

STD.File.DfuPlusExec(cmd);   

// Read all the incoming files
incomingDS := STD.File.RemoteDirectory(lzip, SrcPath, '*.csv');
DeleteInComingFiles := NOTHOR(APPLY(incomingDS,  STD.FILE.DeleteExternalFile(lzIP, srcPath + incomingDS.name)));                                                                                                                                                                                                                                                                           
// DeleteInComingFiles;
