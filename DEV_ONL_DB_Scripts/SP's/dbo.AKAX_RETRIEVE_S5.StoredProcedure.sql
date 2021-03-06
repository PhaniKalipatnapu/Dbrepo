/****** Object:  StoredProcedure [dbo].[AKAX_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AKAX_RETRIEVE_S5] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_Sequence_NUMB            NUMERIC(11, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_TypeAlias_CODE           CHAR(1) OUTPUT,
 @Ac_LastAlias_NAME           CHAR(20) OUTPUT,
 @Ac_FirstAlias_NAME          CHAR(16) OUTPUT,
 @Ac_MiddleAlias_NAME         CHAR(20) OUTPUT,
 @Ac_SuffixAlias_NAME         CHAR(4) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AKAX_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve Unique Sequence Number that will be generated for any given Transaction on the Table from Member Alias Names table for Unique Number Assigned by the System to the Member and sequence number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_TransactionEventSeq_NUMB = NULL,
         @Ac_TypeAlias_CODE = NULL,
         @Ac_LastAlias_NAME = NULL,
         @Ac_FirstAlias_NAME = NULL,
         @Ac_MiddleAlias_NAME = NULL,
         @Ac_SuffixAlias_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB,
         @Ac_TypeAlias_CODE = A.TypeAlias_CODE,
         @Ac_LastAlias_NAME = A.LastAlias_NAME,
         @Ac_FirstAlias_NAME = A.FirstAlias_NAME,
         @Ac_MiddleAlias_NAME = A.MiddleAlias_NAME,
         @Ac_SuffixAlias_NAME = A.SuffixAlias_NAME
    FROM AKAX_Y1 A
   WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.Sequence_NUMB = @An_Sequence_NUMB
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of AKAX_RETRIEVE_S5


GO
