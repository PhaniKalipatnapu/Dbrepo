/****** Object:  StoredProcedure [dbo].[CSPR_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_UPDATE_S2] (
 @An_Request_IDNO           NUMERIC(9, 0),
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_UPDATE_S2
  *     DESCRIPTION       : Update End Validity Date for a Case Idno, TransHeader Idno, TransactionEventSeq_NUMB and Other State Fips Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 13-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE CSPR_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
   WHERE Case_IDNO = @An_Case_IDNO
     AND Request_IDNO = @An_Request_IDNO
     AND IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End of CSPR_UPDATE_S2

GO
