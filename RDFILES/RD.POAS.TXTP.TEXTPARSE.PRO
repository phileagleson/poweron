[
 RD.POAS.TXTP.TEXTPARSE.PRO

-Abstract:
 This include file contains procedures for common text parsing. 

-History:
 Proj. 17.109 Release 2018.01 05/16/2018 kschweers - Initially created.
 Proj. 18.016 Release 2019.00 11/28/2018 kschweers - Adding numeric edit rtns.
 Proj. 20.091 Release 2021.00 11/5/2020 kschweers - Add POASTXTPNOSPACE. 

-Details:
 Common text parsing operations such as removing leading spaces, etc.

-Dependences:
 RD.POAS.CONSTANTS.*
 RD.POAS.TXTP.TEXTPARSE.* 
 RD.POAS.VARIABLES.DEF
]

[
 Remove leading and trailing spaces from a character.
 
 Input:  POASTXTPSTRING - Text string to be operated upon.
 Output: POASTXTPSTRING - Text string without leading/trailing spaces.
]
 PROCEDURE POASTXTPNOLEADTRAIL
  CALL POASTXTPNOLEADSPACE
  CALL POASTXTPNOTRAILSPACE
 END

[
 Remove leading spaces from a character.
 
 Input:  POASTXTPSTRING - Text string to be operated upon.
 Output: POASTXTPSTRING - Text string without leading spaces.
]
PROCEDURE POASTXTPNOLEADSPACE
 POASTXTPCNTR=1
 WHILE SEGMENT(POASTXTPSTRING,POASTXTPCNTR,POASTXTPCNTR)=" " AND
       POASTXTPCNTR<=LENGTH(POASTXTPSTRING)
  DO
   POASTXTPCNTR=POASTXTPCNTR+1
  END
 IF POASTXTPCNTR<=LENGTH(POASTXTPSTRING) THEN
  DO
   POASTXTPSTRING=SEGMENT(POASTXTPSTRING,POASTXTPCNTR,LENGTH(POASTXTPSTRING))
  END
 ELSE
  DO
   POASTXTPSTRING=""
  END
END

[
 Remove trailing spaces from a character.
 
 Input:  POASTXTPSTRING - Text string to be operated upon.
 Output: POASTXTPSTRING - Text string without trailing spaces.
]
PROCEDURE POASTXTPNOTRAILSPACE
 POASTXTPCNTR=LENGTH(POASTXTPSTRING)
 WHILE SEGMENT(POASTXTPSTRING,POASTXTPCNTR,POASTXTPCNTR)=" " AND
       POASTXTPCNTR>0
  DO
   POASTXTPCNTR=POASTXTPCNTR-1
  END
 IF POASTXTPCNTR>0 THEN 
  DO
   POASTXTPSTRING=SEGMENT(POASTXTPSTRING,1,POASTXTPCNTR)
  END
 ELSE
  DO
   POASTXTPSTRING=""
  END
END

[
 Remove all spaces from a character.
 
 Input:  POASTXTPSTRING - Text string to be operated upon.
 Output: POASTXTPSTRING - Text string without any spaces.
]
PROCEDURE POASTXTPNOSPACE
 POASTXTPDONE=FALSE
 WHILE POASTXTPDONE=FALSE
  DO
   POASTXTPCNTR=CHARACTERSEARCH(POASTXTPSTRING," ")
   IF POASTXTPCNTR=0 THEN 
    DO
     POASTXTPDONE=TRUE
    END
   ELSE IF POASTXTPCNTR=LENGTH(POASTXTPSTRING) THEN 
    DO
     POASTXTPSTRING=SEGMENT(POASTXTPSTRING,1,POASTXTPCNTR-1)
     POASTXTPDONE=TRUE
    END
   ELSE
    DO 
     POASTXTPSTRING=SEGMENT(POASTXTPSTRING,1,POASTXTPCNTR-1)+
      SEGMENT(POASTXTPSTRING,POASTXTPCNTR+1,LENGTH(POASTXTPSTRING))
    END
  END
END

[
 Process a list of codes into a single continuous string by simply removing any 
 characters which are not alphabetic.  Normally a list is comma delimited.
 O,A,C becomes OAC.  This allows subsequent use of CHARACTERSEARCH to determine
 if a code value is in the list.  Longer values are also supported.  For 
 example, ABC,D becomes ABCD.  
 
 Input:  POASTXTPLISTSTRING - The input delimited Code List to be processed.
 Output: POASTXTPCODELIST - The compressed Code List.
]
PROCEDURE POASTXTPCODEPARSE
 POASTXTPCODELIST=""
 IF POASTXTPLISTSTRING<>"" THEN 
  DO
   FOR POASTXTPI=1 TO LENGTH(POASTXTPLISTSTRING)
    DO
     IF (SEGMENT(POASTXTPLISTSTRING,POASTXTPI,POASTXTPI)>="A" AND
         SEGMENT(POASTXTPLISTSTRING,POASTXTPI,POASTXTPI)<="Z") OR
        (SEGMENT(POASTXTPLISTSTRING,POASTXTPI,POASTXTPI)>="a" AND
         SEGMENT(POASTXTPLISTSTRING,POASTXTPI,POASTXTPI)<="z") THEN
      DO
       POASTXTPCODELIST=POASTXTPCODELIST+SEGMENT(POASTXTPLISTSTRING,POASTXTPI,
        POASTXTPI)
      END  
    END
  END
END

[
 Process a list of numbers and number ranges and return them in a two 
 dimensional array.  The first dimension is for each distinct number or range.
 The second dimension stores two values: From and Thru.  
 
 Numbers and ranges must be delimited by a comma.  A range is defined by a 
 number followed by a dash followed by another number.  Spaces are allowed
 before or after the comma, and before and after the dash.
   
 The input text can consist single number (901), a list of numbers (901,903), a 
 range of numbers (900 - 903), a list of ranges (900-903 , 910-920) or any 
 combination thereof.
  
 NOTE: For ease of use, single numbers are stored as both From and Thru so that
 a >= AND <= test can always be used on the results.

 Input:  POASTXTPLISTSTRING - The input text containing a list of numbers and 
         number ranges. 
 Output: POASTXTPNUMRNG - An array of number ranges.
         POASTXTPRANGECOUNT - The number of elements in the 1st array dimension.
         POASTXTPERROR - Error Message.
]
PROCEDURE POASTXTPRANGEPARSE
 [ Initialize ]
 POASTXTPERROR=""
 POASTXTPRANGECOUNT=0
 FOR POASTXTPI=1 TO POASTXTPMAXNUMRANGE
  DO
   POASTXTPNUMRNG(POASTXTPI,POASTXTPSUBNUMFROM)=-1
   POASTXTPNUMRNG(POASTXTPI,POASTXTPSUBNUMTHRU)=-1
  END
 
 [ Check for non-blank parameter passed. ]
 IF POASTXTPLISTSTRING<>"" THEN 
  DO
   [ Parse the list into individual values. ]
   POASTXTPLISTDELIMS=COMMA
   CALL POASTXTPLISTPARSE
   IF POASTXTPERROR="" AND
      POASTXTPLISTCOUNT>0 THEN 
    DO
     [ Process each of the values for a number or number range. ]
     FOR POASTXTPI=1 TO POASTXTPLISTCOUNT
      DO
       POASTXTPNUMRANGE=POASTXTPLISTVALUE(POASTXTPI)
       CALL POASTXTPRANGEVALUE
      END
    END
  END
END

[
 Process the number or number range into a number array.  If the input is a 
 single number, the resulting number will be placed into both the "From" and 
 "Thru" array entries.
 
 Input:  POASTXTPNUMRANGE - A string containing one number or number range.
 Output: POASTXTPNUMRNG - An array of number ranges.
         POASTXTPRANGECOUNT - The number of elements in the 1st array dimension.
         POASTXTPERROR - Error Message.
         POASTXTPNUMRANGE - This field is modified as a number range is
         processed.
]
PROCEDURE POASTXTPRANGEVALUE
 [ Initialize. ]
 POASTXTPNUM1NUM=0
 POASTXTPNUM2NUM=0
 
 IF POASTXTPNUMRANGE<>"" THEN 
  DO
   [ Check for a number range. ]
   POASTXTPDASHPOS=CHARACTERSEARCH(POASTXTPNUMRANGE,"-")
   IF POASTXTPDASHPOS>0 THEN 
    DO
     [ Extract the "From" number out of the range. ]
     POASTXTPNUM1CHR=SEGMENT(POASTXTPNUMRANGE,1,POASTXTPDASHPOS-1)
     IF LENGTH(POASTXTPNUMRANGE)>POASTXTPDASHPOS THEN 
      DO
       POASTXTPNUM2CHR=SEGMENT(POASTXTPNUMRANGE,POASTXTPDASHPOS+1,
        LENGTH(POASTXTPNUMRANGE))
      END
     ELSE
      DO
       POASTXTPNUM2CHR=POASTXTPNUM1CHR
      END
    END 
   ELSE [ No Dash found ]
    DO
     POASTXTPNUM1CHR=POASTXTPNUMRANGE
     POASTXTPNUM2CHR=POASTXTPNUM1CHR
    END
    
   [ Convert the number text to a number data type value. ]
   POASTXTPNUM1NUM=VALUE(POASTXTPNUM1CHR)
   POASTXTPNUM2NUM=VALUE(POASTXTPNUM2CHR)
  END [ Non-blank input ]
  
 [ Add the range to the array. ]
 POASTXTPRANGECOUNT=POASTXTPRANGECOUNT+1
 IF POASTXTPRANGECOUNT>POASTXTPMAXNUMRANGE THEN 
  DO
   POASTXTPERROR="Maximum number of ranges exceeded"
  END
 ELSE
  DO
   POASTXTPNUMRNG(POASTXTPRANGECOUNT,POASTXTPSUBNUMFROM)=POASTXTPNUM1NUM
   POASTXTPNUMRNG(POASTXTPRANGECOUNT,POASTXTPSUBNUMTHRU)=POASTXTPNUM2NUM
  END
END

[
 Remove unsafe characters from a character value.
 
 Input:  POASTXTPUNSAFEIN - The string to process for unsafe characters.
 Output: POASTXTPUNSAFEOUT - The returned string with no unsafe characters.
]
PROCEDURE POASTXTPREMOVEUNSAFE
 [ Initialize. ]
 POASTXTPUNSAFEOUT=""
 POASTXTPDONE=FALSE 
 
 [ Loop until all unsafe characters have been processed. ]
 WHILE POASTXTPDONE=FALSE
  DO
   [ Locate the first unsafe character.  ]
   
   [ Code copied here to reduce chance of call stack overflow. ] 
   [ CALL POASTXTPUNSAFECHECK ]
   POASTXTPLASTPOS=0
   [ Loop through a fixed array of unsafe characters which must be escaped. ]
   FOR POASTXTPCNTR=1 TO POASTXTPUNSAFECHARMAX
    DO
     POASTXTPSINGLECHAR=POASTXTPUNSAFECHARS(POASTXTPCNTR)
     POASTXTPDELIMPOS=CHARACTERSEARCH(POASTXTPUNSAFEIN,POASTXTPSINGLECHAR)
     [ If an unsafe character was found, track the one found first in the string.]
     IF POASTXTPDELIMPOS>0 AND 
      (POASTXTPLASTPOS=0 OR
       POASTXTPDELIMPOS<POASTXTPLASTPOS) THEN
      DO
       POASTXTPLASTPOS=POASTXTPDELIMPOS
      END
    END [Unsafe Character Array loop]  
   [ END - CALL POASTXTPUNSAFECHECK ]
   
   [ If an unsafe character was found, escape it. ]
   IF POASTXTPLASTPOS>0 THEN 
    DO
    
     [ Code copied here to reduce chance of call stack overflow. ]
     [ CALL POASTXTPUNSAFEESCAPE ]
     [ Build the output string concatenating safe portion of the input string. ]
     POASTXTPUNSAFEOUT=                                         [ current output  ]
      POASTXTPUNSAFEOUT+                                        [  string         ]
      SEGMENT(POASTXTPUNSAFEIN,1,POASTXTPLASTPOS-1)+            [ safe string     ]
      "\"+                                                      [ escape          ]
      SEGMENT(POASTXTPUNSAFEIN,POASTXTPLASTPOS,POASTXTPLASTPOS) [ unsafe character]
     [ If the unsafe character was not the last character in the input string, ] 
     IF POASTXTPLASTPOS<LENGTH(POASTXTPUNSAFEIN) THEN
      DO
       [ Reset the input string to the remainder of the original input string. ]
       POASTXTPUNSAFEIN=
        SEGMENT(POASTXTPUNSAFEIN,POASTXTPLASTPOS+1,LENGTH(POASTXTPUNSAFEIN))
      END
     [ The unsafe character was the last character in the input string. ]
     ELSE
      DO
       [ The input string goes to null as there is nothing left to process. ]
       POASTXTPUNSAFEIN=""
      END 
     [ END - CALL POASTXTPUNSAFEESCAPE ]  
     
    END [Unsafe character found]
   [ When no unsafe character is found, finalize the output string. ]
   ELSE
    DO 
     POASTXTPUNSAFEOUT=POASTXTPUNSAFEOUT+POASTXTPUNSAFEIN
     POASTXTPDONE=TRUE
    END [No unsafe character found]  
  END [While not DONE]
END

[ 
 Check for the presence of an unsafe character in the input string.  Track the
 first location of any unsafe character in the input string.
 
 Input:  POASTXTPUNSAFEIN - The string to process for unsafe characters.  
         POASTXTPUNSAFECHARS - Array of unsafe characters to escape.         
 Output: POASTXTPLASTPOS - Position of the first unsafe character.  0 If none.
]
PROCEDURE POASTXTPUNSAFECHECK
 POASTXTPLASTPOS=0
 [ Loop through a fixed array of unsafe characters which must be escaped. ]
 FOR POASTXTPCNTR=1 TO POASTXTPUNSAFECHARMAX
  DO
   POASTXTPSINGLECHAR=POASTXTPUNSAFECHARS(POASTXTPCNTR)
   POASTXTPDELIMPOS=CHARACTERSEARCH(POASTXTPUNSAFEIN,POASTXTPSINGLECHAR)
   [ If an unsafe character was found, track the one found first in the string.]
   IF POASTXTPDELIMPOS>0 AND 
    (POASTXTPLASTPOS=0 OR
     POASTXTPDELIMPOS<POASTXTPLASTPOS) THEN
    DO
     POASTXTPLASTPOS=POASTXTPDELIMPOS
    END
  END [Unsafe Character Array loop]
END

[ 
 Remove one unsafe character from a string.  The output string is concatenated
 with the safe portion of the input string.  The input string is reset to that
 trailing portion past the unsafe character just escaped.
 
 Input:  POASTXTPUNSAFEIN - The string to process for unsafe characters.
         POASTXTPUNSAFEOUT - The current output string. 
         POASTXTPLASTPOS - Position of the current unsafe character.                 
 Output: POASTXTPUNSAFEOUT - The output string with escaped unsafe character.
         POASTXTPUNSAFEIN - The remaining portion of the string to process. 
]
PROCEDURE POASTXTPUNSAFEESCAPE
 [ Build the output string concatenating safe portion of the input string. ]
 POASTXTPUNSAFEOUT=                                          [ current output  ]
  POASTXTPUNSAFEOUT+                                         [  string         ]
  SEGMENT(POASTXTPUNSAFEIN,1,POASTXTPLASTPOS-1)+             [ safe string     ]
  "\"+                                                       [ escape          ]
  SEGMENT(POASTXTPUNSAFEIN,POASTXTPLASTPOS,POASTXTPLASTPOS)  [ unsafe character]

 [ If the unsafe character was not the last character in the input string, ] 
 IF POASTXTPLASTPOS<LENGTH(POASTXTPUNSAFEIN) THEN
  DO
   [ Reset the input string to the remainder of the original input string. ]
   POASTXTPUNSAFEIN=
    SEGMENT(POASTXTPUNSAFEIN,POASTXTPLASTPOS+1,LENGTH(POASTXTPUNSAFEIN))
  END
 [ The unsafe character was the last character in the input string. ]
 ELSE
  DO
   [ The input string goes to null as there is nothing left to process. ]
   POASTXTPUNSAFEIN=""
  END
END

[
 Parses a delimited list into an array.  
 
 Values may be delimited by one or more characters specified by the input 
 character variable POASTXTPLISTDELIMS.  The first delimiter found past the last 
 one will define the next value.  Null values may be created by specifying a 
 delimiter as the first character, last character, or two adjacent delimiters.

 Input:  POASTXTPLISTSTRING - A list of values.  (ABC,123,do,re,mi)
         POASTXTPLISTDELIMS - One or more single-byte delimiters to be used.
                              Will default to comma if none specified.
 Output: POASTXTPLISTVALUE - The list returned in a character array.
         POASTXTPLISTCOUNT - The number of parsed list values in the array.
         POASTXTPERROR - Error Message.
]
PROCEDURE POASTXTPLISTPARSE
 [ Initialize. ]
 POASTXTPLASTPOS=0
 POASTXTPDONE=FALSE
 POASTXTPLISTCOUNT=0
 POASTXTPERROR=""
 IF POASTXTPLISTDELIMS="" THEN 
  DO
   POASTXTPLISTDELIMS=COMMA
  END
 FOR POASTXTPI=1 TO POASTXTPMAXLIST
  DO
   POASTXTPLISTVALUE(POASTXTPI)=""
  END

 [ Loop through the input list string, parsing out delimited values. ]
 IF LENGTH(POASTXTPLISTSTRING)>0 THEN
  DO
   WHILE POASTXTPDONE=FALSE 
    DO
     POASTXTPNULLVAL=FALSE
     
     [ Locate the next delimiter. ]
     CALL POASTXTPLISTPARSEFIND

     [ Set the stop position for the current value. ]
     CALL POASTXTPLISTPARSESTOP

     [ Get the next value and add it to the returned array. ]
     CALL POASTXTPLISTPARSEADD
     
     [ Set position of the previous delimiter for next loop. ]
     POASTXTPLASTPOS=POASTXTPDELIMPOS
     
     [ If no delimiter or error, the list processing is completed. ]
     IF POASTXTPDELIMFOUND=FALSE OR
        POASTXTPERROR<>"" THEN 
      DO
       POASTXTPDONE=TRUE
      END 
    END [ Loop until no more values ]
  END [ If input is not null ]
END

[
 Find the location in the list of the next closest delimiter for 
 POASTXTPLISTPARSE.

 Input:  POASTXTPLISTSTRING - A list of values.  (ABC,123,do,re,mi)
         POASTXTPLISTDELIMS - One or more single-byte delimiters to be used.
         POASTXTPLASTPOS - The absolute location of the previous delimiter.
 Output: POASTXTPRELPOS - The relative position of a located delimiter.
         POASTXTPNULLVAL - Boolean: Null value - last char was a delimiter.
         POASTXTPDELIMFOUND - Boolean: A delimiter was found.
]
PROCEDURE POASTXTPLISTPARSEFIND
 [ Initialize. ]
 POASTXTPRELPOS=LENGTH(POASTXTPLISTSTRING)+1
 POASTXTPDELIMFOUND=FALSE
 
 [ Loop through the delimiter list. ]
 IF POASTXTPLASTPOS<LENGTH(POASTXTPLISTSTRING) THEN
  DO
   FOR POASTXTPI=1 TO LENGTH(POASTXTPLISTDELIMS)
    DO
     [ Search for the current delimiter. ]
     POASTXTPFIRSTPOS=CHARACTERSEARCH(SEGMENT(POASTXTPLISTSTRING,
      POASTXTPLASTPOS+1,LENGTH(POASTXTPLISTSTRING)),
      SEGMENT(POASTXTPLISTDELIMS,POASTXTPI,POASTXTPI))
     [ If found and at earlier position than previous search, set found info. ]
     IF POASTXTPFIRSTPOS<>0 AND
        POASTXTPFIRSTPOS<POASTXTPRELPOS THEN 
      DO
       POASTXTPDELIMFOUND=TRUE
       POASTXTPRELPOS=POASTXTPFIRSTPOS
      END 
    END [ Loop through delimiters ]
  END [ If last char was not a delimiter ]
 ELSE
  DO
   POASTXTPNULLVAL=TRUE
  END [ Last character of the list was a delimiter ]
END

[
 Set the "stop" position in the input string of the current value being parsed
 for POASTXTPLISTPARSE.

 Input:  POASTXTPLISTSTRING - A list of values.  (ABC,123,do,re,mi)
         POASTXTPRELPOS - The relative location of the current delimiter.
         POASTXTPLASTPOS - The absolute location of the previous delimiter.
         POASTXTPDELIMFOUND - A current delimiter was found.
 Output: POASTXTPDELIMPOS - The absolute position of a located delimiter.
         POASTXTPNULLVAL - Boolean: Null value - two adjacent delimiters.
         POASTXTPLISTSTOP - Absolute end location of the current value.
]
PROCEDURE POASTXTPLISTPARSESTOP 
 [ If a delimiter was found, ]
 IF POASTXTPDELIMFOUND=TRUE THEN
  DO
   [ Compute absolute delimiter position in the input list string. ]
   POASTXTPDELIMPOS=POASTXTPRELPOS+POASTXTPLASTPOS
   [ If the delimiter is not adjacent to the last one.] 
   IF POASTXTPDELIMPOS>POASTXTPLASTPOS+1 THEN
    [ Set the segment stop to the character prior to the delimiter. ]
    DO
     POASTXTPLISTSTOP=POASTXTPDELIMPOS-1
    END
   ELSE
    [ Two adjacent delimiters creates a null value. ]
    DO
     POASTXTPNULLVAL=TRUE
    END
  END
 ELSE
  [ If no delimiter found, the segment stop is the last input list character. ]
  DO
   POASTXTPLISTSTOP=LENGTH(POASTXTPLISTSTRING)
  END
END

[ 
 Add the current list value to the returned array for POASTXTPLISTPARSE.

 Input:  POASTXTPLISTSTRING - A list of values.  (ABC,123,do,re,mi)
         POASTXTPNULLVAL - Boolean: The current value is null.
         POASTXTPLISTSTOP - Absolute end location of the current value.
         POASTXTPLASTPOS - The absolute location of the previous delimiter.
 Output: POASTXTPLISTVALUE - The current value added to the returned array.
         POASTXTPLISTCOUNT - Updated count of values in the returned array.
         POASTXTPSTRING - The current list value (may be null).
         POASTXTPERROR - Error Message.
]
PROCEDURE POASTXTPLISTPARSEADD
 [ Set the current value; either null or a value out of the input list string. ]
 IF POASTXTPNULLVAL=TRUE THEN
  DO
   POASTXTPSTRING=""
  END
 ELSE
  DO
   POASTXTPSTRING=SEGMENT(POASTXTPLISTSTRING,POASTXTPLASTPOS+1,
    POASTXTPLISTSTOP)
   CALL POASTXTPNOLEADTRAIL
  END   

 [ Add the current value to the next returned array entry. ]
 POASTXTPLISTCOUNT=POASTXTPLISTCOUNT+1
 IF POASTXTPLISTCOUNT>POASTXTPMAXLIST THEN
  DO
   POASTXTPERROR="Maximum number of values in list exceeded"
  END      
 ELSE
  DO
   POASTXTPLISTVALUE(POASTXTPLISTCOUNT)=POASTXTPSTRING     
  END    
END

[
 Main Procedure for the Numeric Edit routine.
  
 Edit a character format numeric item for data format and numeric value.
 The interpreted numeric value is returned in the data type specific variables.
 The numeric value is then formatted according to the input data format.  This 
  character value is returned in POASTXTPEDCHR.
 Spaces are removed, any truncation needed based on POASTXTPEDOUTLEN is done,
  and the result returned in POASTXTPSTRING.
 The Numeric Code input data format is treated slightly differently in that 
  leading zeroes are formatted versus spaces in unused positions.  Therefore the
  POASTXTPEDOUTLEN should normally be specified with this format to format a 
  character return value of the correct length. 

 Input:  POASTXTPSTRING - A value to be edited.
         POASTXTPEDINPFMT - Input data format (see POASTXTPFMT* for codes)..
         POASTXTPEDOUTLEN - Output data length for POASTXTPSTRING return value.
                            0=no restriction; retain FORMAT() character length.
 Output: POASTXTPERROR - Error Message.
         POASTXTPERRORCD - Error Code.
             0=Good Translation
             1=Null Input Value
             2=Invalid Character in Input
             3=Invalid Money Format
             4=Invalid Rate Format
             5=Invalid Date Format
             6=Invalid Time Format
         POASTXTPSTRING - Returned value in character format no spaces and 
                         truncated if needed.
         POASTXTPEDCHR - Return value re-formatted as CHARACTER (raw).                          
         POASTXTPEDNUM - Return value when the input format is NUMBER.
         POASTXTPEDMNY - Return value when the input format is MONEY.
         POASTXTPEDDAT - Return value when the input format is DATE.
         POASTXTPEDTIM - Return value when the input format is TIME.
         POASTXTPEDRAT - Return value when the input format is RATE.                 
]
PROCEDURE POASTXTPEDNUMERIC
 [ Initialize variables. ]
 CALL POASTXTPEDINIT
 
 [ Pre-Process the input value. ]
 CALL POASTXTPEDPREPROCESS
 
 [ Build list of valid characters for the input data format. ]
 IF POASTXTPERRORCD=0 THEN 
  CALL POASTXTPEDCHARLIST
 
 [ Edit the format of the input data. ]
 IF POASTXTPERRORCD=0 THEN 
  DO
   IF POASTXTPEDINPFMT<>POASTXTPFMTDAT OR
     (POASTXTPEDINPFMT=POASTXTPFMTDAT AND
      POASTXTPSTRING<>"--/--/--" AND 
      POASTXTPSTRING<>"--/--/----") THEN 
     CALL POASTXTPEDVALIDFORMAT
  END  
  
 [ Set the data type specific return variables to the input value. ]
 IF POASTXTPERRORCD=0 THEN 
  CALL POASTXTPEDSETRETURNS
 
 [ Reformat the return value as character per the specified input data format. ]
 IF POASTXTPERRORCD=0 THEN
  CALL POASTXTPEDREFORMAT
END

[
 Initialize for a new numeric Edit call.

 Input:  N/A
 Output: Initialized variables.
 
]
PROCEDURE POASTXTPEDINIT
 POASTXTPERROR=""
 POASTXTPERRORCD=0
 POASTXTPEDNUM=0
 POASTXTPEDMNY=$0.00
 POASTXTPEDCHR=""
 POASTXTPEDDAT='--/--/----'
 POASTXTPEDTIM=0
 POASTXTPEDRAT=0.000% 
END

[
 Perform some pre-processing of the input value.  Check for null values, and 
 whatever other "up-front" processing may be needed.

 Input:  POASTXTPSTRING - Input value.
         POASTXTPEDINPFMT - Input data format (see POASTXTPFMT* for codes)..
 Output: POASTXTPSTRING - Pre-Processed input value.
         POASTXTPERROR - Error Message.
         POASTXTPERRORCD - Error Code.
]
PROCEDURE POASTXTPEDPREPROCESS
 [ Remove extraneous spaces. ]
 CALL POASTXTPNOLEADTRAIL

 [ Check for a null input value. ] 
 IF POASTXTPSTRING="" THEN 
  DO
   POASTXTPERRORCD=1
   POASTXTPERROR="Input value is null"
  END
END

[
 Build a list of valid characters accepted in the input value based on the input
 data format specified.

 Input:  POASTXTPEDINPFMT - Input data format (see POASTXTPFMT* for codes).. 
 Output: POASTXTPEDVALIDCHAR - List of valid characters.  
]
PROCEDURE POASTXTPEDCHARLIST
 POASTXTPEDVALIDCHAR="0123456789"
 IF POASTXTPEDINPFMT=POASTXTPFMTMNY THEN 
  DO
   POASTXTPEDVALIDCHAR=POASTXTPEDVALIDCHAR+",+-$."
  END
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTNUM THEN
  DO
   POASTXTPEDVALIDCHAR=POASTXTPEDVALIDCHAR+",+-"
  END 
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTDAT THEN
  DO
   POASTXTPEDVALIDCHAR=POASTXTPEDVALIDCHAR+"/"
  END
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTTIM THEN
  DO
   POASTXTPEDVALIDCHAR=POASTXTPEDVALIDCHAR+":"
  END
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTRAT THEN
  DO
   POASTXTPEDVALIDCHAR=POASTXTPEDVALIDCHAR+"%."
  END     
END

[
 Edit the input value based on the specified input data format.
 
 Input:  POASTXTPSTRING - Input value.
         POASTXTPEDINPFMT - Input data format (see POASTXTPFMT* for codes)..
         POASTXTPEDVALIDCHAR - List of valid characters for input data format.
 Output: POASTXTPERROR - Error Message.
         POASTXTPERRORCD - Error Code. 
]
PROCEDURE POASTXTPEDVALIDFORMAT
 [ Edit for valid characters in the value. ]
 POASTXTPCNTR=LENGTH(POASTXTPSTRING)
 POASTXTPI=1
 WHILE (POASTXTPERRORCD=0 AND POASTXTPI<=POASTXTPCNTR)
  DO
   POASTXTPSINGLECHAR=SEGMENT(POASTXTPSTRING,POASTXTPI,POASTXTPI)
   POASTXTPLASTPOS=CHARACTERSEARCH(POASTXTPEDVALIDCHAR,POASTXTPSINGLECHAR)
   IF POASTXTPLASTPOS=0 THEN 
    DO
     POASTXTPERRORCD=2
     POASTXTPERROR="Invalid character found: "+POASTXTPSINGLECHAR
    END
   POASTXTPI=POASTXTPI+1
  END [While loop]
  
 [ Edit for a valid format based on the input data format specified. ]
 IF POASTXTPERRORCD=0 THEN 
  DO
   IF POASTXTPEDINPFMT=POASTXTPFMTMNY THEN
    DO
     POASTXTPSINGLECHAR=SEGMENT(POASTXTPSTRING,POASTXTPCNTR,POASTXTPCNTR)
     IF POASTXTPSINGLECHAR="+" OR POASTXTPSINGLECHAR="-" THEN
      POASTXTPLASTPOS=POASTXTPCNTR-3
     ELSE
      POASTXTPLASTPOS=POASTXTPCNTR-2
     IF POASTXTPLASTPOS<0 OR 
        SEGMENT(POASTXTPSTRING,POASTXTPLASTPOS,POASTXTPLASTPOS)<>"." THEN
      DO
       POASTXTPERRORCD=3
       POASTXTPERROR="Invalid MONEY format"      
      END 
    END [Money format]
   ELSE IF POASTXTPEDINPFMT=POASTXTPFMTRAT THEN
    DO
     POASTXTPSINGLECHAR=SEGMENT(POASTXTPSTRING,POASTXTPCNTR,POASTXTPCNTR)
     IF POASTXTPSINGLECHAR="%" THEN
      POASTXTPLASTPOS=POASTXTPCNTR-4
     ELSE
      POASTXTPLASTPOS=POASTXTPCNTR-3   
     IF POASTXTPLASTPOS<0 OR 
        SEGMENT(POASTXTPSTRING,POASTXTPLASTPOS,POASTXTPLASTPOS)<>"." THEN
      DO
       POASTXTPERRORCD=4
       POASTXTPERROR="Invalid RATE format"      
      END
    END [Rate format]
   ELSE IF POASTXTPEDINPFMT=POASTXTPFMTDAT THEN
    DO
     POASTXTPLASTPOS=POASTXTPCNTR-4
     POASTXTPFIRSTPOS=POASTXTPCNTR-7
     IF POASTXTPLASTPOS>0 AND POASTXTPFIRSTPOS>0 THEN
      DO
       IF SEGMENT(POASTXTPSTRING,POASTXTPLASTPOS,POASTXTPLASTPOS)="/" THEN 
        DO
         IF SEGMENT(POASTXTPSTRING,POASTXTPFIRSTPOS,POASTXTPFIRSTPOS)<>"/" THEN
          DO
           POASTXTPERRORCD=5
           POASTXTPERROR="Invalid DATE format"        
          END
        END [Check mm/dd/yyyy format]
      END [Long Length]
     IF POASTXTPERRORCD=0 THEN
      DO
       POASTXTPLASTPOS=POASTXTPCNTR-2
       POASTXTPFIRSTPOS=POASTXTPCNTR-5
       IF POASTXTPLASTPOS>0 AND POASTXTPFIRSTPOS>0 THEN 
        DO
         IF SEGMENT(POASTXTPSTRING,POASTXTPLASTPOS,POASTXTPLASTPOS)="/" THEN 
          DO
           IF SEGMENT(POASTXTPSTRING,POASTXTPFIRSTPOS,POASTXTPFIRSTPOS)<>"/" THEN
            DO
             POASTXTPERRORCD=5
             POASTXTPERROR="Invalid DATE format"        
            END         
          END [Check mm/dd/yy format]
        END [Short Length]         
      END [No error yet]     
    END [Date format]
   ELSE IF POASTXTPEDINPFMT=POASTXTPFMTTIM THEN
    DO
     POASTXTPLASTPOS=POASTXTPCNTR-2
     IF SEGMENT(POASTXTPSTRING,POASTXTPLASTPOS,POASTXTPLASTPOS)<>":" THEN 
      DO
       POASTXTPERRORCD=6
       POASTXTPERROR="Invalid TIME format"       
      END    
    END [Time format]      
  END [No error yet]
END

[
 Set data type specific return variables from the character input value.

 Input:  POASTXTPSTRING - Input value.
         POASTXTPEDINPFMT - Input data format (see POASTXTPFMT* for codes)..
 Output: POASTXTPEDNUM - Return value when the input format is NUMBER or 
                         NUMERIC CODE.
         POASTXTPEDMNY - Return value when the input format is MONEY.         
         POASTXTPEDDAT - Return value when the input format is DATE.
         POASTXTPEDTIM - Return value when the input format is TIME.
         POASTXTPEDRAT - Return value when the input format is RATE.          
]
PROCEDURE POASTXTPEDSETRETURNS
 IF POASTXTPEDINPFMT=POASTXTPFMTMNY THEN
  DO 
   POASTXTPEDMNY=MONEY(VALUE(POASTXTPSTRING))
   POASTXTPCNTR=LENGTH(POASTXTPSTRING)
   IF SEGMENT(POASTXTPSTRING,POASTXTPCNTR,POASTXTPCNTR)="-" THEN 
    POASTXTPEDMNY=POASTXTPEDMNY*(-1) 
  END
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTNUM THEN
  DO
   POASTXTPEDNUM=NUMBER(VALUE(POASTXTPSTRING))
   POASTXTPCNTR=LENGTH(POASTXTPSTRING)
   IF SEGMENT(POASTXTPSTRING,POASTXTPCNTR,POASTXTPCNTR)="-" THEN 
    POASTXTPEDNUM=POASTXTPEDNUM*(-1)      
  END
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTCOD THEN
  POASTXTPEDNUM=NUMBER(VALUE(POASTXTPSTRING)) 
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTDAT THEN
  POASTXTPEDDAT=DATEVALUE(POASTXTPSTRING) 
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTTIM THEN 
  POASTXTPEDTIM=NUMBER(VALUE(POASTXTPSTRING))          
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTRAT THEN 
  POASTXTPEDRAT=RATE(VALUE(POASTXTPSTRING)/100000)    
END

[
 Reformat the data type specific input value as a character field.

 Input:  POASTXTPEDINPFMT - Input data format (see POASTXTPFMT* for codes)..
         POASTXTPEDNUM - Return value when the input format is NUMBER.
         POASTXTPEDMNY - Return value when the input format is MONEY.         
         POASTXTPEDDAT - Return value when the input format is DATE.
         POASTXTPEDTIM - Return value when the input format is TIME.
         POASTXTPEDRAT - Return value when the input format is RATE. 
 Output: POASTXTPEDCHR - Return input value re-formatted as CHARACTER (raw).
         POASTXTPSTRING - Return character input value no spaces and truncated.
]
PROCEDURE POASTXTPEDREFORMAT
 [ Format the return character value based on the input data format. ]
 IF POASTXTPEDINPFMT=POASTXTPFMTMNY THEN 
  POASTXTPEDCHR=FORMAT("#############9.99+",POASTXTPEDMNY)
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTNUM THEN
  POASTXTPEDCHR=FORMAT("###############9+",POASTXTPEDNUM)
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTCOD THEN
  POASTXTPEDCHR=FORMAT("9999999999999999",POASTXTPEDNUM)  
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTDAT THEN
  POASTXTPEDCHR=FORMAT("99/99/9999",POASTXTPEDDAT)
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTTIM THEN 
  POASTXTPEDCHR=FORMAT("99:99",POASTXTPEDTIM)          
 ELSE IF POASTXTPEDINPFMT=POASTXTPFMTRAT THEN 
  POASTXTPEDCHR=FORMAT("##9.999",POASTXTPEDRAT) 

 [ If an output length was specified, truncate the value at that length. ]
 IF LENGTH(POASTXTPEDCHR)>0 THEN 
  DO
   POASTXTPSTRING=POASTXTPEDCHR
   CALL POASTXTPNOLEADTRAIL
   POASTXTPCNTR=LENGTH(POASTXTPSTRING)
   IF POASTXTPCNTR>0 THEN 
    DO
     IF POASTXTPEDOUTLEN>0 AND 
        POASTXTPCNTR>POASTXTPEDOUTLEN THEN
      DO
       POASTXTPSTRING=SEGMENT(POASTXTPSTRING,
                              POASTXTPCNTR-POASTXTPEDOUTLEN+1,
                              POASTXTPCNTR)
      END [Truncation needed]
    END [Compressed non-zero length] 
  END [Raw non-zero length]
END
