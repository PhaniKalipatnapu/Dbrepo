/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S68]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S68] (
 @Ac_Worker_ID                CHAR(30),
 @An_Office_IDNO              NUMERIC(3),
 @Ac_Role_ID                  CHAR(10),
 @An_CasesAssigned_QNTY       NUMERIC(10) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S68
  *     DESCRIPTION       : Retrieve  Case Assigned and Sequential Transaction event for the USRL Key.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/24/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SET @An_TransactionEventSeq_NUMB = NULL;
  SET @An_CasesAssigned_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = U.TransactionEventSeq_NUMB,
         @An_CasesAssigned_QNTY = U.CasesAssigned_QNTY
    FROM USRL_Y1 U
   WHERE U.Worker_ID = @Ac_Worker_ID
     AND U.Office_IDNO = @An_Office_IDNO
     AND U.Role_ID = @Ac_Role_ID
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
