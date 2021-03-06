/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S53]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S53] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_Barcode_NUMB   NUMERIC(12, 0),
 @Ac_Subsystem_CODE CHAR(2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S53
  *     DESCRIPTION       : Retrieve the first Subsystem Code for a given Case and Barcode.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Subsystem_CODE = NULL;

  SELECT TOP 1 @Ac_Subsystem_CODE = D.Subsystem_CODE
    FROM UDMNR_V1 D
         JOIN FORM_Y1 F
          ON D.Topic_IDNO = F.Topic_IDNO
   WHERE F.Barcode_NUMB = @An_Barcode_NUMB
     AND D.Case_IDNO = @An_Case_IDNO;
 END; --End Of Procedure DMNR_RETRIEVE_S53  

GO
