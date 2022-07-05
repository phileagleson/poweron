[
 RD.POAS.READ.PARSE.INPUT.PRO

-Abstract:
This include file contains procedures needed for 
 PowerOn as a Service programs to use standardized
 procedures to read in and parse input.

-History:
 Project 17.067 Release 2018.00 2/9/2018 William Morgan Original Author

-Details:
 The variables defined are required for the following include files:
 RD.READ.PARSE.INPUT.PRO

 These procedures are used to capture input being passed into the 
 PowerOn as a Service specfiles. There are two procedures that are to
 be used when a PowerOn as a service specfile is receiving input 
 describing a single object, and two procedures that are to be used 
 when receiving input describing an array of objects.

 Single object procedures:
  READINPUT
  PARSEINPUT

 Array of objects procedures:
  READPARSEINPUTOBJARRAY
  INITOBJFIELDVALUES

-Dependences:
 RD.READ.PARSE.INPUT.DEF
 
 Use of this include file requires that the PowerOn as a Service 
 contain a procedure named USEOBJFIELDVALUES. 

   If the specfile is processing input describing a single object 
   this procedure will  be empty.

   If the specfile is processing input describing an array of objects
   this procedure contains specfile specific code that moves the
   parsed data into local arrays 
]

[
 This procedure reads in the contents of the input buffer and
 loads each name value pair into an array element.

 Use this procedure if the input is a set of name values pairs
 describing a single object.
]
PROCEDURE READINPUT
 INPUTCTR=0
 WHILE INPUTCTR<=999 AND
       INPUTLINE(INPUTCTR)<>"EOD"
  DO
   INPUTCTR=INPUTCTR+1
   INPUTLINE(INPUTCTR)=ENTERLINE(2)
  END
END

[
 This procedure parses the name value pairs and loads them
 into separate arrays.

 Use this procedure if the input is a set of name values pairs
 describing a single object.
]
PROCEDURE PARSEINPUT
 FOR I=1 TO INPUTCTR
  DO
   PARSELOC=CHARACTERSEARCH(INPUTLINE(I),"=")
   NAMEARRAY(I)=SEGMENT(INPUTLINE(I),1,PARSELOC-1)
   VALUEARRAY(I)=SEGMENT(INPUTLINE(I),PARSELOC+1,LENGTH(INPUTLINE(I)))
  END
END

[
 This procedure reads and parses the input buffer when it contains sets
 of name value pairs that make up an array of objects. Each set of name
 value pairs describing a single instance of the array is read, parsed,
 and transferred to arrays in the calling program before reading the name 
 value pairs for the next array instance.

 The code to transfer the data to the calling specfiles arrays must be 
 in a procedure named USEOBJFIELDVALUES that is coded in the PowerOn as 
 a Service specfile

 After the data is transferred into the PowerOn as Service specfile, the 
 array OBJFIELDVALUES must be initialized.
]
PROCEDURE READPARSEINPUTOBJARRAY
 RAWNAMEVALUE=""
 WHILE RAWNAMEVALUE<>"EOD"
  DO
   RAWNAMEVALUE=ENTERLINE(2)
   PARSELOC=CHARACTERSEARCH(RAWNAMEVALUE,"=")
   NAMESEG=SEGMENT(RAWNAMEVALUE,1,PARSELOC-1)
   VALUESEG=SEGMENT(RAWNAMEVALUE,PARSELOC+1,LENGTH(RAWNAMEVALUE))
   
   IF NAMESEG="messageId" THEN
    DO
     MESSAGEID=VALUESEG
    END
   ELSE
    DO   
     FOR FIELDCTR=1 TO OBJFIELDSMAX
      DO
       IF NAMESEG=OBJFIELDNAMES(FIELDCTR) THEN
        DO
         OBJFIELDVALUES(FIELDCTR)=VALUESEG
        END
      END
     IF OBJFIELDVALUES(OBJFIELDSMAX)<>"" THEN
      DO
       CALL USEOBJFIELDVALUES
       CALL INITOBJFIELDVALUES
      END
    END
  END
END

[
 This procedure initializes the contents of the OBJFIELDVALUES
 array between the processing of object array elements.
]
PROCEDURE INITOBJFIELDVALUES
 FOR FIELDCTR=1 TO OBJFIELDSMAX
  DO
   OBJFIELDVALUES(FIELDCTR)=""
  END
END
