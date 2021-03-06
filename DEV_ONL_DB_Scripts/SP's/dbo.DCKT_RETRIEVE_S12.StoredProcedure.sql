/****** Object:  StoredProcedure [dbo].[DCKT_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCKT_RETRIEVE_S12] (
 @Ac_File_ID        CHAR(10),
 @As_CaseTitle_NAME VARCHAR(60) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DCKT_RETRIEVE_S12
  *     DESCRIPTION       : Retrives the Case Title for the respective Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_CaseTitle_NAME = NULL;

  SELECT @As_CaseTitle_NAME = D.CaseTitle_NAME
    FROM DCKT_Y1 D
   WHERE D.File_ID = @Ac_File_ID;
 END; -- END OF DCKT_RETRIEVE_S12

GO
