/****** Object:  StoredProcedure [dbo].[CRAS_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[CRAS_RETRIEVE_S3]  

     @An_Office_IDNO                        NUMERIC(3)               ,
     @Ai_Count_QNTY                            NUMERIC(11)             OUTPUT
AS

/*
 *     PROCEDURE NAME    : CRAS_RETRIEVE_S3
 *     DESCRIPTION       : Retrieve the Row Count for a Office, where Request Type is Reassignment Request for an Office, and where Status Code is Pending Request.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

      SET @Ai_Count_QNTY = NULL
      DECLARE
         @Lc_No_TEXT CHAR(1) = 'N', 
         @Ps_CdTypeRequestO_CNST CHAR(1)= 'O';
      SELECT @Ai_Count_QNTY = COUNT(1)
      FROM CRAS_Y1 C
      WHERE 
         C.Office_IDNO = @An_Office_IDNO AND 
         C.TypeRequest_CODE = @Ps_CdTypeRequestO_CNST AND 
         C.Status_CODE = @Lc_No_TEXT;
END


GO
