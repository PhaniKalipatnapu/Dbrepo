/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S5](
 @An_Application_IDNO         NUMERIC(15, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) = NULL,
 @An_WelfareMemberMci_IDNO    NUMERIC(10, 0) OUTPUT,
 @Ad_End_DATE                 DATE OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : APMH_RETRIEVE_S5    
  *     DESCRIPTION       : gets the Welfare Identification of the Member for the given Application Id, Member Id,  Transaction Event Sequence where enddate validity is highdate.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 22-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SELECT @An_WelfareMemberMci_IDNO = NULL,
         @Ad_End_DATE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_WelfareMemberMci_IDNO = A.WelfareMemberMci_IDNO,
         @Ad_End_DATE = A.End_DATE
    FROM APMH_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A.TransactionEventSeq_NUMB = ISNULL(@An_TransactionEventSeq_NUMB, A.TransactionEventSeq_NUMB);
 END; -- End Of APMH_RETRIEVE_S5


GO
