/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 *     PROCEDURE NAME    : USRL_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Transaction sequence and Alpha Assignment Range provided to the Worker for an Office, Role Idno, and Worker Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S2](
 @An_Office_IDNO              NUMERIC(3),
 @Ac_Role_ID                  CHAR(10),
 @Ac_Worker_ID                CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT,
 @Ac_AlphaRangeFrom_CODE      CHAR(5) OUTPUT,
 @Ac_AlphaRangeTo_CODE        CHAR(5) OUTPUT
 )
AS
 BEGIN
  SET @An_TransactionEventSeq_NUMB = NULL;
  SET @Ac_AlphaRangeFrom_CODE = NULL;
  SET @Ac_AlphaRangeTo_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = U.TransactionEventSeq_NUMB,
         @Ac_AlphaRangeFrom_CODE = U.AlphaRangeFrom_CODE,
         @Ac_AlphaRangeTo_CODE = U.AlphaRangeTo_CODE
    FROM USRL_Y1 U
   WHERE U.Office_IDNO = @An_Office_IDNO
     AND U.Role_ID = @Ac_Role_ID
     AND U.Worker_ID = @Ac_Worker_ID
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
