/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S30](
	 @An_MemberMci_IDNO   NUMERIC(10, 0),
	 @Ac_TypeAddress_CODE CHAR(1),
	 @Ac_Status_CODE      CHAR(1),
	 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) = NULL,
	 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AHIS_RETRIEVE_S30
  *     DESCRIPTION       : To Check whether Already active address exists on this type
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/23/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SET @Ai_Count_QNTY = 0;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM AHIS_Y1 A
   WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.TypeAddress_CODE = @Ac_TypeAddress_CODE
     AND A.Status_CODE = @Ac_Status_CODE
     AND A.End_DATE = @Ld_High_DATE
     AND A.TransactionEventSeq_NUMB != ISNULL(@An_TransactionEventSeq_NUMB,  0);
 END 
 -- END OF AHIS_RETRIEVE_S30

GO
