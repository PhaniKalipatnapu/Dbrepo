/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S11](
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT
 )
AS
/*
*     PROCEDURE NAME    : USRT_RETRIEVE_S11
*     DESCRIPTION       : Retrieve the Transaction Event for a High Profile Case and Member MCI.
*     DEVELOPED BY      : IMP TEAM
*     DEVELOPED ON      : 25-OCT-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
 BEGIN
  SET @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Lc_Yes_TEXT  CHAR(1) = 'Y',
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = U.TransactionEventSeq_NUMB
    FROM USRT_Y1 U
   WHERE U.MemberMci_IDNO = @An_MemberMci_IDNO
     AND U.Case_IDNO = @An_Case_IDNO
     AND U.HighProfile_INDC = @Lc_Yes_TEXT
     AND U.End_DATE = @Ld_High_DATE
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
