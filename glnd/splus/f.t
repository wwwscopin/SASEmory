f.top <- function(file,meeting.date,enroll.date,fup.date,
 header=c("IATS","ENROLLMENT","REPORT"),
 landscape=F)
{
file.tex <- paste(file,"tex",sep=".")
report.top <- c(paste(header,collapse=" "),
 " \\hspace{2em}",c(meeting.date,"\\hfill","\\hspace{3em}"))

report.top <- c(
"\\documentclass[dvips,10pt]{article}",
"\\usepackage{graphicx}",
if(landscape) 
c(
"\\setlength{\\oddsidemargin}{-0.3in}",
"\\setlength{\\textwidth}{9.5in}",
"\\setlength{\\topmargin}{-0.70in}",
"\\setlength{\\textheight}{7.0in}") else 
c(
"\\setlength{\\oddsidemargin}{-0.3in}",
"\\setlength{\\textwidth}{7.0in}",
"\\setlength{\\topmargin}{-0.70in}",
"\\setlength{\\textheight}{9.5in}"),
"\\pagestyle{myheadings}",
"\\markright{ {\\rm {", report.top, "}}}",
"\\headsep=0.2in",
"\\begin{document}")

cat(report.top,file=file.tex,sep="\n")

cat(c("\\vspace*{1in}","\\begin{center}",
 "{\\Huge{IATS ENROLLMENT REPORT}}","\\end{center}"),
 file=file.tex,sep="\n", append=T)
cat(c("\\begin{center}",
 paste("{\\Huge{",meeting.date,"}}"),"\\end{center}"),
 file=file.tex,sep="\n", append=T)
cat(c("\\vspace*{0.5in}","\\begin{center}",
 "{\\Huge{CONFIDENTIAL}}","\\end{center}"),
 file=file.tex,sep="\n", append=T)

cat(c("\\vspace*{3.5in}","\\begin{center}",
 "\\noindent",
 paste("{\\Large{Includes patients enrolled as of ",enroll.date,".}}",sep=""),
 "", "\\vspace*{1em}",
 paste("{\\Large{Includes follow-up data received as of ",fup.date,"}}",sep=""),
 "\\end{center}","\\clearpage"),
 file=file.tex,sep="\n", append=T)

cat(c("\\vspace*{1in}","\\begin{center}",
 "{\\Large{IATS ENROLLMENT REPORT}}","\\end{center}"),
 file=file.tex,sep="\n", append=T)

cat(c("\\listoftables","\\listoffigures","\\clearpage"),file=file.tex,sep="\n",
 append=T)
return(NULL)
}

