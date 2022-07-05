[
 RD.POAS.JSON.CREATION.PRO

-Abstract:
 This include file contains procedures needed for
 PowerOn as a Service programs to use standardized
 procedures to create response JSON.

-History:
 Proj. 17.067 Release 2018.00 2/9/2018 William Morgan Original Author
 Proj 12.114.13 Release 2021.00 08/18/2020 kschweers - Add character handling
  procedure which removes unsafe characters.

-Details:
 The procedures require the following include files:
 RD.JSON.CREATION.SET
 RD.JSON.CREATION.PRO

 This set of include files streamlines the development of PowerOn as a
 Service specfiles by providing a standardized process to create
 response JSON.

 Each procedures purpose is described in a comment, placed before the
 procedure.

-Dependences:
 RD.POAS.CONSTANTS.*
 RD.POAS.JSON.CREATION.*
 RD.POAS.TXTP.TEXTPARSE.*

-History:
 Proj 18.016 Release 2019.00 8/8/2018 kschweers.  Added START/CONTINUE/END tags.
]

[
-Purpose:
 Creates the header required to identify the beginning of the JSON response
 and sets the root name for the JSON.

 MAINOBTJNAME contents are loaded in the PowerOn as a Service specfile just
 before calling this procedure.

 Must be called at the beginning of the creation of a response JSON.
]
PROCEDURE POASJSONHEADER
 PRINT POASJSONSTARTMARK                     [ Send a Start marker.            ]
 JSON(JSONCTR)="Json~Type=PowerOn~Value={"+  [ Add JSON header syntax.         ]
               Q+MAINOBJNAME+Q+":{"
END
PROCEDURE CREATEJSONHEADER
 CALL POASJSONHEADER
END

[
 Generate a numeric JSON field entry.

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUEMONEY - The value of the field in MONEY format.
 Return: POASJSONVALUECHAR - The value of the field in CHAR format.
         JSON() - A field entry in the JSON array.
]
PROCEDURE POASJSONFIELDMONEY
 POASTXTPSTRING=FORMAT("#############9.99+",POASJSONVALUEMONEY)
 CALL POASTXTPNOLEADTRAIL
 POASJSONVALUECHAR=POASTXTPSTRING
 CALL POASJSONFIELDCHARSAFE
END

[
 Generate a numeric JSON field entry.

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUENUM - The value of the field in NUMBER format.
 Return: POASJSONVALUECHAR - The value of the field in CHAR format.
         JSON() - A field entry in the JSON array.
]
PROCEDURE POASJSONFIELDNUM
 POASTXTPSTRING=FORMAT("#########9+",POASJSONVALUENUM)
 CALL POASTXTPNOLEADTRAIL
 POASJSONVALUECHAR=POASTXTPSTRING
 CALL POASJSONFIELDCHARSAFE
END

[
 Generate a rate JSON field entry.

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUERATE - The value of the field in RATE format.
 Return: POASJSONVALUECHAR - The value of the field in CHAR format.
         JSON() - A field entry in the JSON array.
]
PROCEDURE POASJSONFIELDRATE
 POASTXTPSTRING=FORMAT("##9.999",POASJSONVALUERATE)
 CALL POASTXTPNOLEADTRAIL
 POASJSONVALUECHAR=POASTXTPSTRING
 CALL POASJSONFIELDCHARSAFE
END

[
 Generate a date JSON field entry.

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUEDATE - The value of the field in DATE format.
 Return: POASJSONVALUECHAR - The value of the field in CHAR format.
         JSON() - A field entry in the JSON array.
]
PROCEDURE POASJSONFIELDDATE
 POASJSONVALUECHAR=FORMAT("99/99/9999",POASJSONVALUEDATE)
 CALL POASJSONFIELDCHARSAFE
END

[
 Generate a time JSON field entry.

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUETIME - The value of the field in NUMBER format.
 Return: POASJSONVALUECHAR - The value of the field in CHAR format.
         JSON() - A field entry in the JSON array.
]
PROCEDURE POASJSONFIELDTIME
 POASJSONVALUECHAR=FORMAT("99:99",POASJSONVALUETIME)
 CALL POASJSONFIELDCHARSAFE
END

[
 Generate a formatted time JSON field entry.
 The time will be in a format like "8:30a" or "12:45p".

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUETIME - The value of the field in NUMBER format.
 Return: POASJSONVALUECHAR - The value of the field in CHAR format.
         JSON() - A field entry in the JSON array.
]
PROCEDURE POASJSONFIELDFORMATTEDTIME
 IF HOUR(POASJSONVALUETIME)=0 THEN
  POASJSONVALUECHAR="12"
 ELSE IF HOUR(POASJSONVALUETIME)<13 THEN
  POASJSONVALUECHAR=FORMAT("#9",HOUR(POASJSONVALUETIME))
 ELSE
  POASJSONVALUECHAR=FORMAT("#9",HOUR(POASJSONVALUETIME)-12)

 POASJSONVALUECHAR=POASJSONVALUECHAR+":"+FORMAT("99",MINUTE(POASJSONVALUETIME))

 IF HOUR(POASJSONVALUETIME)<12 THEN
  POASJSONVALUECHAR=POASJSONVALUECHAR+"a"
 ELSE
  POASJSONVALUECHAR=POASJSONVALUECHAR+"p"

 CALL POASJSONFIELDCHARSAFE
END

[
 Generate a character JSON field entry handling unsafe characters.

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUECHAR - The value of the field in CHARACTER format.
 Return: POASJSONVALUECHAR - The value of the field in CHARACTER format.
         JSON() - A field entry in the JSON array.
]
PROCEDURE POASJSONFIELDCHARUS
 POASTXTPUNSAFEIN=POASJSONVALUECHAR
 CALL POASTXTPREMOVEUNSAFE
 TEMPCHAR=Q+POASJSONFIELD+Q+":"
 CALL POASJSONLOADJSONARRAY
 TEMPCHAR=Q+POASTXTPUNSAFEOUT+Q
 CALL POASJSONLOADJSONARRAY
END

[
 Generate a character JSON field entry.
 Use when POASJSONFIELD cannot contain any unsafe characters (like " and \).

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUECHAR - The value of the field in CHARACTER format.
 Return: JSON() - A field entry in the JSON array
]
PROCEDURE POASJSONFIELDCHARSAFE
 TEMPCHAR=Q+POASJSONFIELD+Q+":"
 CALL POASJSONLOADJSONARRAY
 TEMPCHAR=Q+POASJSONVALUECHAR+Q
 CALL POASJSONLOADJSONARRAY
END

[
 Generate a character JSON field entry.
 Currently set to use the unsafe character handling procedure.  

 Pass:   POASJSONFIELD - The name of the field to be generated.
         POASJSONVALUECHAR - The value of the field in CHARACTER format.
 Return: JSON() - A field entry in the JSON array
]
PROCEDURE POASJSONFIELDCHAR
[ Repeated code instead of below call to reduce chance of call stack overflow. ]
[ CALL POASJSONFIELDCHARUS call stack reduction]
 POASTXTPUNSAFEIN=POASJSONVALUECHAR
 CALL POASTXTPREMOVEUNSAFE
 TEMPCHAR=Q+POASJSONFIELD+Q+":"
 CALL POASJSONLOADJSONARRAY
 TEMPCHAR=Q+POASTXTPUNSAFEOUT+Q
 CALL POASJSONLOADJSONARRAY
END

[
 Generate an array value (no keyword just a character value).
 Handles unsafe characters.

 Pass:   POASJSONVALUECHAR - The value of the field in CHARACTER format.
 Return: JSON() - A field entry in the JSON array
]
PROCEDURE POASJSONCHARARRAYUS
 POASTXTPUNSAFEIN=POASJSONVALUECHAR
 CALL POASTXTPREMOVEUNSAFE
 TEMPCHAR=Q+POASTXTPUNSAFEOUT+Q
 CALL POASJSONLOADJSONARRAY
END

[
 Generate an array value (no keyword just a character value).
 Does not handle unsafe characters.

 Pass:   POASJSONVALUECHAR - The value of the field in CHARACTER format.
 Return: JSON() - A field entry in the JSON array
]
PROCEDURE POASJSONCHARARRAYSAFE
 TEMPCHAR=Q+POASJSONVALUECHAR+Q
 CALL POASJSONLOADJSONARRAY
END

[
 Generate an array value (no keyword just a character value).
 Currently set to use the unsafe character handling procedure.  
 
 Pass:   POASJSONVALUECHAR - The value of the field in CHARACTER format.
 Return: JSON() - A field entry in the JSON array
]
PROCEDURE POASJSONCHARARRAY
 [CALL POASJSONCHARARRAYUS call stack reduction] 
 POASTXTPUNSAFEIN=POASJSONVALUECHAR
 CALL POASTXTPREMOVEUNSAFE
 TEMPCHAR=Q+POASTXTPUNSAFEOUT+Q
 CALL POASJSONLOADJSONARRAY 
END

[
-Purpose:
 Creates the beginning of a JSON array object.

 DATAOBJNAME contents are loaded in the PowerOn as a Service specfile just
 before calling this procedure.
]
PROCEDURE POASJSONSTARTARRAYOBJ
 TEMPCHAR=Q+DATAOBJNAME+Q+":["
 CALL POASJSONLOADJSONARRAY
END
PROCEDURE STARTJSONARRAYDATAOBJ
 CALL POASJSONSTARTARRAYOBJ
END

[
-Purpose:
 Ends a JSON array object.
]
PROCEDURE POASJSONENDARRAYOBJ
 TEMPCHAR="]"
 CALL POASJSONLOADJSONARRAY
END
PROCEDURE ENDJSONARRAYDATAOBJ
 CALL POASJSONENDARRAYOBJ
END

[
 Start a JSON data object.

 Pass:   DATAOBJNAME
 Return: JSON() - JSON array entry to start a data object.
]
PROCEDURE POASJSONSTARTOBJ
 TEMPCHAR=Q+DATAOBJNAME+Q+":{"
 CALL POASJSONLOADJSONARRAY
END

[
 Ends a JSON data object.
]
PROCEDURE POASJSONENDOBJ
 CALL POASJSONCLOSECURLY
END

[
 Creates the beginning of a curly bracket entry.
]
PROCEDURE POASJSONOPENCURLY
 TEMPCHAR="{"
 CALL POASJSONLOADJSONARRAY
END

[
 Creates the end of a curly bracket entry.
]
PROCEDURE POASJSONCLOSECURLY
 TEMPCHAR="}"
 CALL POASJSONLOADJSONARRAY
END

[
 Creates a comma entry.
]
PROCEDURE POASJSONCOMMA
 TEMPCHAR=","
 CALL POASJSONLOADJSONARRAY
END

[
 Add a JSON Error message entry.

 Pass:   POASJSONMESSAGE - The message text.
 Return: ERRORMSG() - Error Message array entry.
]
PROCEDURE POASJSONMSGERROR
 STATUSTYPE=STATUSTYPEERROR
 [CALL POASJSONMSGADD call stack reduction]
 ERRORMSGCTR=ERRORMSGCTR+1
 POASTXTPUNSAFEIN=POASJSONMESSAGE
 CALL POASTXTPREMOVEUNSAFE
 ERRORMSG(ERRORMSGCTR)=POASTXTPUNSAFEOUT
END

[
 Add a JSON message entry.

 Pass:   POASJSONMESSAGE - The message text.
 Return: ERRORMSG() - Message array entry.
]
PROCEDURE POASJSONMSGADD
 ERRORMSGCTR=ERRORMSGCTR+1
 POASTXTPUNSAFEIN=POASJSONMESSAGE
 CALL POASTXTPREMOVEUNSAFE
 ERRORMSG(ERRORMSGCTR)=POASTXTPUNSAFEOUT
END

[
-Purpose:
 Loads each piece of the JSON into an array in preparation for sending the
 response JSON.

 Input:  TEMPCHAR - The current piece of JSON syntax to be added.
 Output: JSON() - A JSON syntax array entry.
         JSONCTR - Index to the current JSON syntax array entry.
]
PROCEDURE POASJSONLOADJSONARRAY
 CALL POASJSONCHECKLENGTH
 JSON(JSONCTR)=JSON(JSONCTR)+TEMPCHAR
 IF JSONCTR=POASJSONMAXJSON THEN           [ Detect JSON syntax array overflow.]
  DO
   POASJSONMARKER=POASJSONCONTMARK         [ Add a Continue marker.            ]
   CALL POASJSONOUTPUTJSON                 [ Output the current JSON syntax.   ]
   PRINT POASJSONSTARTMARK                 [ Send a Start marker.              ]
  END
END
PROCEDURE LOADJSONARRAY
 CALL POASJSONLOADJSONARRAY
END

[
-Purpose:
 Ensures that the maximum number of characters per character array element
 is not exceeded when assembling the response JSON.

 Input:  JSON() - The current JSON syntax array entry.
         TEMPCHAR - The current piece of JSON syntax to be added.
         JSONCTR - Index to the current JSON syntax array entry.
 Output: JSONCTR - New index to the current JSON syntax array entry.
]
PROCEDURE POASJSONCHECKLENGTH
 IF LENGTH(JSON(JSONCTR))+                 [ Detect JSON syntax array entry    ]
    LENGTH(TEMPCHAR)>130 THEN              [ overflow.                         ]
  DO
   JSONCTR=JSONCTR+1                       [ Start new JSON syntax array entry.]
  END
END

[
-Purpose:
 Creates the status message JSON object with informational or error messages.

 STATUSTYPE defaults to Success. Is changed to Error for any outcomes that
 prevent the specfile from continuing. Remains as Success if the message
 generated is informational.

 One or more messages can be returned. A blank message is returned if no
 informational or error messages were loaded.

 ERRORMSG is loaded in the PowerOn as a Service specfile for any condition
 that requires informational or error messages to be returned.

 ERRORMSGCTR is incremented before loading an error or informational
 message in the PowerOn as a Service specfile and is used as the index
 to the ERRRORMSG array when loading the array.

 Must be called when creating every response JSON.
]
PROCEDURE POASJSONERRORMSG
 TEMPCHAR=Q+"status"+Q+":{"
 CALL POASJSONLOADJSONARRAY
 TEMPCHAR=Q+"type"+Q+":"+Q+STATUSTYPE+Q+","
 CALL POASJSONLOADJSONARRAY
 TEMPCHAR=Q+"messages"+Q+":["
 CALL POASJSONLOADJSONARRAY
 IF ERRORMSGCTR=0 THEN
  DO
   TEMPCHAR=Q+Q
   CALL POASJSONCHECKLENGTH
   CALL POASJSONLOADJSONARRAY
  END
 ELSE
  DO
   FOR J=1 TO ERRORMSGCTR
    DO
     IF J>1 THEN
      DO
       JSON(JSONCTR)=JSON(JSONCTR)+","
      END
     TEMPCHAR=Q+ERRORMSG(J)+Q
     CALL POASJSONCHECKLENGTH
     CALL POASJSONLOADJSONARRAY
    END
  END
 TEMPCHAR="]}"
 CALL POASJSONLOADJSONARRAY
END
PROCEDURE CREATEJSONERRORMSG
 CALL POASJSONERRORMSG
END
[
-Purpose:
 Ends the response JSON.

 Must be called after all other portions of the JSON creation are completed.

 Input:  JSONCTR - Number of JSON array entries.
 Output: JSON() - Closing brackets to end the JSON syntax.
         JSONCTR - Number of JSON array entries.
         POASJSONMARKER - #END# to denote end of JSON syntax.
]
PROCEDURE POASJSONFOOTER
 JSONCTR=JSONCTR+1
 JSON(JSONCTR)=JSON(JSONCTR)+"}}"
 POASJSONMARKER=POASJSONENDMARK
END
PROCEDURE CREATEJSONFOOTER
 CALL POASJSONFOOTER
END

[
-Purpose:
 Outputs the response JSON.

 Must be called after calling CREATEJSONFOOTER.

 Input:  POASJSONMARKER - Either #CONTINUE# or #END# marker.
         JSON() - Array of JSON syntax.
         JSONCTR - Number of JSON array entries.
 Output: Standard Out - JSON syntax from the JSON array.
         MSGLENGTH - Length of the JSON syntax plus length of the marker.
]
PROCEDURE POASJSONOUTPUTJSON
 WHILELIMIT=10000000

 MSGLENGTH=0
 FOR POASJSONJ=0 TO JSONCTR
  DO
   MSGLENGTH=MSGLENGTH+LENGTH(JSON(POASJSONJ))+1
  END

 [ Adjust MSGLENGTH for the #CONTINUE or #END# marker. ]
 [ Note that #END# marker will have CR appended by system; add +1 to adjust. ]
 MSGLENGTH=MSGLENGTH+LENGTH(POASJSONMARKER)
 IF POASJSONMARKER=POASJSONENDMARK THEN
  DO
   MSGLENGTH=MSGLENGTH+1
  END

 [ Add 1 for the NEWLINE after the next NEWLINE. ]
 MSGLENGTH=MSGLENGTH+1
 PRINT FORMAT("99999999",MSGLENGTH)
 NEWLINE

 [ Output the current batch of JSON and clear the array for the next batch. ]
 FOR POASJSONJ=0 TO JSONCTR
  DO
   PRINT JSON(POASJSONJ)
   NEWLINE
   JSON(POASJSONJ)=""
  END

 [ #CONTINUE# or #END# depending. ]
 PRINT POASJSONMARKER

 [ Reset for next batch of JSON if any. ]
 JSONCTR=0
 MSGLENGTH=0
END
PROCEDURE OUTPUTJSON
 CALL POASJSONOUTPUTJSON
END
