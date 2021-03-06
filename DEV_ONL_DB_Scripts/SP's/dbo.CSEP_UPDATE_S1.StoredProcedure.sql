/****** Object:  StoredProcedure [dbo].[CSEP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSEP_UPDATE_S1] (
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Function_CODE          CHAR(3),
 @Ac_CertMode_INDC          CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME	: CSEP_UPDATE_S1
  *     DESCRIPTION      : Endvalidating the record for a Given State and CSENet Function
  *     DEVELOPED BY     : IMP Team
  *     DEVELOPED ON     : 03-AUG-2011
  *     MODIFIED BY      : 
  *     MODIFIED ON      : 
  *     VERSION NO       : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE CSEP_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
   WHERE IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND Function_CODE = @Ac_Function_CODE
     AND CertMode_INDC <> ISNULL (@Ac_CertMode_INDC, CertMode_INDC)
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF CSEP_UPDATE_S1


GO
