###################################################
# --- BEGIN: ONLY CHANGE HERE ---
#--------------------------------------------------
$thisRepo = @{
	GitHub_Username = "alexoah"
	QuestionSource = "W3School"
}
#--------------------------------------------------
# --- END: ONLY CHANGE HERE ---
###################################################


###################################################
# --- BEGIN: RESERVE FOR LATER ---
#--------------------------------------------------
$theReadmeTxt = @{
	txtHeader = ""
	txtBodyContent = ""
	txtFooter = ""
}
$thisRepo += @{
	BaseName = ""
	MainFolder = ""
	
	ReadmeFile = ""
	CSVFile = ""
	
	TemplateContent = ""
	LessonCode = ""
	PrefixCode = ""
	SuffixCode = "E" 
	FileExtension = ""
}
#--------------------------------------------------
# answer file's name format: $thisRepo.PrefixCode + ExerciseName + $thisRepo.SuffixCode + QuestionNumber + $thisRepo.FileExtension
# example: htExerciseAbbrNameE3.html
#--------------------------------------------------
$curAnswerFile = @{
	ExerciseName = ""
	QuestionNumber = 0
	Folder = ""
	FileLocation = ""
	txtContentTemplate = ""
}
#--------------------------------------------------
# --- END: RESERVE FOR LATER ---
###################################################

###################################################
# --- BEGIN: Exercises entries ---
# the template for $currentExercise: (ExerciseName, QuestionURL, TutorialURL, QuestionNumber)
#--------------------------------------------------
$currentExercise = @()

$thisRepo.BaseName = [System.IO.Path]::GetFileNameWithoutExtension((Get-Variable MyInvocation).Value.MyCommand.Name)
$thisRepo.CSVFile = $thisRepo.BaseName+".csv"
try {
	if (((Test-Path ($thisRepo.CSVFile) -PathType leaf) -and (Test-Path ($thisRepo.BaseName+".txt") -PathType leaf)) -eq $false) { stop }
	$currentExercise = (Import-CSV -Path $thisRepo.CSVFile -Header @("ExerciseName", "QuestionURL", "TutorialURL", "Number", "StandardFileExtension", "LessonCode", "PrefixCode") -Delimiter (Get-Culture).TextInfo.ListSeparator)
	$thisRepo.TemplateContent = [string](Get-Content -Path ($thisRepo.BaseName+".txt") | Out-String) #-join ""
} catch {
	"Failed to create needed directories and files. Process terminated.`r`n"
	Exit
}

#--------------------------------------------------
# for HEADER, Introduction & template: everything needed in $currentExercise[0] row
#--------------------------------------------------
$thisRepo.LessonCode = (&{if($currentExercise[0].LessonCode.Length -gt 0) {$currentExercise[0].LessonCode} else {($currentExercise[0].ExerciseName).Substring(0, 2).ToUpper()}})
$thisRepo.PrefixCode = (&{if($currentExercise[0].PrefixCode.Length -gt 0) {($currentExercise[0].PrefixCode).ToLower()} else {$thisRepo.LessonCode.Substring(0, 2).ToLower()}})

$thisRepo.MainFolder = $thisRepo.QuestionSource + "-"+ $thisRepo.LessonCode + "Exercises"
$thisRepo.ReadmeFile = $thisRepo.MainFolder + "\" + "README.md"
$thisRepo.FileExtension = ($currentExercise[0].StandardFileExtension).ToLower()

$theReadmeTxt = @{
	txtHeader = "# Introduction"+"`r`n"+"All these files are from doing [" + $thisRepo.QuestionSource + "s' "+$currentExercise[0].ExerciseName+" Exercises]("+$currentExercise[0].QuestionURL+")  "+"`r`n"+"Total: "+$currentExercise[0].Number+" Exercises."
	txtBodyContent = ""
	txtFooter = "`r`n`r`n"+"##"+"`r`n"+"<sup>:octocat: Created by [@"+$thisRepo.GitHub_Username+"](http://github.com/"+$thisRepo.GitHub_Username+") at GitHub.</sup>"
}

#--------------------------------------------------
# for Directories, Files & text of README:
# START looping from $currentExercise[1], because $currentExercise[0] is only for HEADER
#--------------------------------------------------
#for ($cur_QuestionNumber=1; $cur_QuestionNumber -lt 2; $cur_QuestionNumber++) {
for ($cur_QuestionNumber=1; $cur_QuestionNumber -lt $currentExercise.count; $cur_QuestionNumber++) {
	$curAnswerFile.ExerciseName=$currentExercise[$cur_QuestionNumber].ExerciseName -replace " ", ""
	$curAnswerFile.QuestionNumber=([int32]$currentExercise[$cur_QuestionNumber].Number)

	# example of directory path: W3School-HTMLExercises\HTML-Images
	$curAnswerFile.Folder = $thisRepo.MainFolder+"\"+$thisRepo.LessonCode+"-"+$curAnswerFile.ExerciseName
	try {
		if (!(Test-Path $curAnswerFile.Folder -PathType Container)) { mkdir $curAnswerFile.Folder }
	} catch {
		"Failed to create directory " + $curAnswerFile.Folder
	}

	###################################################
	# --- BEGIN: create answer files & list them into README ---
	#--------------------------------------------------
	$cur_ReadmeTXT = @{
		LessonTitle = "## ["+$currentExercise[0].ExerciseName+" "+$currentExercise[$cur_QuestionNumber].ExerciseName+"](./"+$thisRepo.LessonCode+"-"+$curAnswerFile.ExerciseName+"): "+$curAnswerFile.QuestionNumber+" exercise" +(&{if($curAnswerFile.QuestionNumber -gt 1) {"s"} else {""}})
		txtTableName = "| " + $thisRepo.QuestionSource + "s [Tutorial]("+$currentExercise[$cur_QuestionNumber].TutorialURL+") |"
		txtTableSeparator = "| :--- |"
		listExercises = "| Exercises |"
		listAnswers = "| Answer |"
	}

	#for($i=1; $i -lt 2; $i++) {
	for($i=1; $i -lt ($curAnswerFile.QuestionNumber+1); $i++) {
		###################################################
		# list of exercises & answer files for README text
		#--------------------------------------------------
		$cur_ReadmeTXT.txtTableName += " "+$i+" |"
		$cur_ReadmeTXT.txtTableSeparator += " --- |"
		$cur_ReadmeTXT.listExercises += " [Q"+$i+"]("+$currentExercise[$cur_QuestionNumber].QuestionURL+$i+") |"
		$cur_ReadmeTXT.listAnswers += " [A"+$i+"](./"+$thisRepo.LessonCode+"-"+$curAnswerFile.ExerciseName+"/"+$thisRepo.PrefixCode+$curAnswerFile.ExerciseName+$thisRepo.SuffixCode+$i+$thisRepo.FileExtension+") |"
		###################################################
		
		###################################################
		# create answer files including their content template
		#--------------------------------------------------
		$curAnswerFile.FileLocation = $curAnswerFile.Folder+"\"+$thisRepo.PrefixCode+$curAnswerFile.ExerciseName+$thisRepo.SuffixCode+$i+$thisRepo.FileExtension;
		#"Current file = " + $curAnswerFile.FileLocation
		
		<#
		$curAnswerFile.txtContentTemplate=
			"<!--" +
				"`n`t" + "from "+$currentExercise[0].ExerciseName+ " " +$currentExercise[$cur_QuestionNumber].ExerciseName+ ": Exercise "+$i+ " ( "+$currentExercise[$cur_QuestionNumber].QuestionURL+$i+" )" +
				"`n`n`t" + "question:" +
				"`n`n`n`n" + "//-->`n"
		#>
		$curAnswerFile.txtContentTemplate = $thisRepo.TemplateContent.Replace("[TEMPLATE_LessonName]", $currentExercise[0].ExerciseName).Replace("[TEMPLATE_ExerciseName]", $currentExercise[$cur_QuestionNumber].ExerciseName).Replace("[TEMPLATE_CurrentQuestionNumber]", $i).Replace("[TEMPLATE_CurrentQuestionURL]", ($currentExercise[$cur_QuestionNumber].QuestionURL+$i))

		if (Test-Path $curAnswerFile.FileLocation -PathType leaf) { Remove-Item $curAnswerFile.FileLocation }
		New-Item -Path $curAnswerFile.FileLocation -ItemType File -Value $curAnswerFile.txtContentTemplate
		###################################################
	}

	$theReadmeTxt.txtBodyContent += "`r`n`r`n" + $cur_ReadmeTXT.LessonTitle +
		"`r`n" + $cur_ReadmeTXT.txtTableName +
		"`r`n" + $cur_ReadmeTXT.txtTableSeparator +
		"`r`n" + $cur_ReadmeTXT.listExercises +
		"`r`n" + $cur_ReadmeTXT.listAnswers
	#--------------------------------------------------
	# --- END: create answer files & list them into README ---
	###################################################
}
#--------------------------------------------------
# --- END: Exercises entries ---
###################################################

###################################################
# --- BEGIN: output the README text into file ---
#--------------------------------------------------
try {
	if (Test-Path $thisRepo.ReadmeFile -PathType leaf) { Remove-Item $thisRepo.ReadmeFile }
	New-Item -Path $thisRepo.ReadmeFile -ItemType File -Value ($theReadmeTxt.txtHeader + $theReadmeTxt.txtBodyContent + $theReadmeTxt.txtFooter)
} catch {
	"Failed to create "+$thisRepo.ReadmeFile+" file"
} finally {
	Exit
}
#--------------------------------------------------
# --- END: output the README text into file ---
###################################################