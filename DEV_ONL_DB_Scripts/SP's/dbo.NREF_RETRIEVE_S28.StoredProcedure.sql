/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S28] (
 @Ac_Notice_ID   CHAR(8),
 @Ac_Exists_INDC CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S28
  *     DESCRIPTION       : Check whether the fips code is required for the given notice. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_TEXT         CHAR(1) = 'N',
          @Lc_Yes_TEXT        CHAR(1) = 'Y',
          @Lc_CategoryIN_CODE CHAR(2) = 'IN',
          @Lc_NoticeINT13_ID  CHAR(6) = 'INT-13',
          @Lc_NoticeINT15_ID  CHAR(6) = 'INT-15',
          @Ld_High_DATE       DATE = '12/31/9999';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM NREF_Y1 N1
   WHERE N1.Notice_ID = @Ac_Notice_ID
     AND N1.Notice_ID NOT IN (@Lc_NoticeINT13_ID, @Lc_NoticeINT15_ID)
     AND Category_CODE = @Lc_CategoryIN_CODE
     AND EndValidity_DATE = @Ld_High_DATE;
 END; --End of NREF_RETRIEVE_S28

GO
