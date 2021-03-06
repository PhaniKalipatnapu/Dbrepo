/****** Object:  StoredProcedure [dbo].[FFCL_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_RETRIEVE_S11] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5),
 @Ac_Exists_INDC   CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_RETRIEVE_S11
  *     DESCRIPTION       : To get the Print Method for Intergovernmental Notice for the Given FAR. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_No_TEXT          CHAR(1) = 'N',
          @Lc_Yes_TEXT         CHAR(1) = 'Y',
          @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_BatchOnline_CODE CHAR(1) = 'I';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM FFCL_Y1 FF
         JOIN NREF_Y1 NR
          ON FF.Notice_ID = NR.Notice_ID
   WHERE FF.Function_CODE = @Ac_Function_CODE
     AND FF.Action_CODE = @Ac_Action_CODE
     AND FF.Reason_CODE = ISNULL(@Ac_Reason_CODE, @Lc_Space_TEXT)
     AND FF.EndValidity_DATE = @Ld_High_DATE
     AND NR.EndValidity_DATE = @Ld_High_DATE
     AND NR.BatchOnline_CODE = @Lc_BatchOnline_CODE;
 END; --END OF FFCL_RETRIEVE_S11



GO
