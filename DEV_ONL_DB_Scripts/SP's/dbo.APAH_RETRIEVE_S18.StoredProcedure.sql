/****** Object:  StoredProcedure [dbo].[APAH_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAH_RETRIEVE_S18](
 @An_Application_IDNO         NUMERIC(15),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*    
 *     PROCEDURE NAME    : APAH_RETRIEVE_S18    
  *     DESCRIPTION       : Retrieve Member Address Type and Unique Sequence Number for an Application ID, Member ID and Member Address Type is Mailing, Primary & Secondary.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-MAR-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT AP.TypeAddress_CODE,
         AP.TransactionEventSeq_NUMB
    FROM APAH_Y1 AP
   WHERE AP.Application_IDNO = @An_Application_IDNO
     AND AP.MemberMci_IDNO = @An_MemberMci_IDNO
     AND AP.TransactionEventSeq_NUMB = ISNULL(@An_TransactionEventSeq_NUMB, AP.TransactionEventSeq_NUMB)
     AND AP.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APAH_RETRIEVE_S18


GO
