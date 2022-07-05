[
 RD.POAS.USEOBJFIELD.NULL.PRO

!!! NOTE: This filename is longer than PowerOn allows (though it will build OK
the editor cannot support it).  This version should be deprecated in favor of
RD.POAS.USEOBJFIELDVALUES.PRO when possible. !!!  

-Abstract:
 This include file contains a null procedure named USEOBJFIELDVALUES. 

-History:
 Proj. 17.109 Release 2018.01 mm/dd/ccyy <who> <what>

-Details:
 RD.POAS.READ.PARSE.INPUT.PRO calls this procedure, but is only used when the 
 input contains an array of objects.  Therefore, this procedure must be defined
 in all programs, but will be null when an input array is not being used. 

-Dependences:
 RD.POAS.READ.PARSE.INPUT.PRO.
]

[
 This empty procedure is required because of the include file
 RD.POAS.READ.PARSE.INPUT.PRO.
]
PROCEDURE USEOBJFIELDVALUES
END
