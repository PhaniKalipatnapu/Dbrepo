/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S27] (
 @Ac_Notice_ID   CHAR(8),
 @Ac_Exists_INDC CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S27
  *     DESCRIPTION       : Check whether the othp id is required for the given notice. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_TEXT           CHAR(1) = 'N',
          @Lc_Yes_TEXT          CHAR(1) = 'Y',
          @Lc_Element_NAME      CHAR(15) = 'OTHERPARTY_IDNO',
          @Lc_BatchOnlineN_CODE CHAR(1) ='N';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM NREF_Y1 N1
   WHERE N1.BatchOnline_CODE = @Lc_BatchOnlineN_CODE
     AND EXISTS (SELECT 1
                   FROM NDEL_Y1 N
                  WHERE N.Notice_ID = N1.Notice_ID
                    AND N.Element_NAME = @Lc_Element_NAME)
     AND N1.Notice_ID = @Ac_Notice_ID;
 END; --End of NREF_RETRIEVE_S27

GO
