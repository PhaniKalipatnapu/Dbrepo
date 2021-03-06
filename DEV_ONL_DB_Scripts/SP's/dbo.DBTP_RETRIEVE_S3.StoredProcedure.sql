/****** Object:  StoredProcedure [dbo].[DBTP_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBTP_RETRIEVE_S3] (
 @Ac_TypeDebt_CODE            CHAR(2),
 @Ac_Interstate_INDC          CHAR(1),
 @Ac_SourceReceipt_CODE       CHAR(2),
 @Ac_TypeWelfare_CODE         CHAR(1),
 @Ac_TypeBucket_CODE          CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @An_PrDistribute_QNTY        NUMERIC(5, 0) OUTPUT
 )
AS
 /*  
 *      PROCEDURE NAME    : DBTP_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieves Distribute priorities and transaction sequence number for the given type debt code, type welfare code, type bucket code.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @An_PrDistribute_QNTY = NULL,
         @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_PrDistribute_QNTY = d.PrDistribute_QNTY,
         @An_TransactionEventSeq_NUMB = d.TransactionEventSeq_NUMB
    FROM DBTP_Y1 d
   WHERE d.TypeDebt_CODE = @Ac_TypeDebt_CODE
     AND d.SourceReceipt_CODE = @Ac_SourceReceipt_CODE
     AND d.Interstate_INDC = @Ac_Interstate_INDC
     AND d.TypeWelfare_CODE = @Ac_TypeWelfare_CODE
     AND d.TypeBucket_CODE = @Ac_TypeBucket_CODE
     AND d.EndValidity_DATE = @Ld_High_DATE;
 END; --End of DBTP_RETRIEVE_S3

GO
