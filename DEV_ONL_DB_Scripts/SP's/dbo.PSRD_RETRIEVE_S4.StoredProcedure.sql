/****** Object:  StoredProcedure [dbo].[PSRD_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PSRD_RETRIEVE_S4] (
       @An_Case_IDNO NUMERIC(6,0),
       @Ac_File_ID   CHAR(10) OUTPUT
       )
  AS
  
/*
 *     PROCEDURE NAME    : PSRD_RETRIEVE_S4
 *     DESCRIPTION       : Fetches the File Number for the given Case IDNO.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

 BEGIN

       SET @Ac_File_ID = NULL;
       
   DECLARE @Lc_ProcessLoad_CODE CHAR(1) ='L';
   
    SELECT @Ac_File_ID = P.File_ID
      FROM PSRD_Y1 P
     WHERE P.Case_IDNO    = @An_Case_IDNO
       AND P.Process_CODE = @Lc_ProcessLoad_CODE; 
       
  END;-- END OF PSRD_RETRIEVE_S4

GO
