/****** Object:  StoredProcedure [dbo].[DBTP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBTP_INSERT_S1] (
 @Ac_TypeDebt_CODE            CHAR(2),
 @Ac_Interstate_INDC          CHAR(1),
 @Ac_SourceReceipt_CODE       CHAR(2),
 @Ac_TypeWelfare_CODE         CHAR(1),
 @Ac_TypeBucket_CODE          CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_PrDistribute_QNTY        NUMERIC(5, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*  
 *     PROCEDURE NAME     : DBTP_INSERT_S1  
  *     DESCRIPTION       : Insert a new record into the Debt Type Priority table for the given type debt code, interstate, type welfare code & type bucket code. 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT DBTP_Y1
         (TypeDebt_CODE,
          SourceReceipt_CODE,
          Interstate_INDC,
          TypeWelfare_CODE,
          TypeBucket_CODE,
          PrDistribute_QNTY,
          Worker_ID,
          BeginValidity_DATE,
          EndValidity_DATE,
          Update_DTTM,
          TransactionEventSeq_NUMB)
  VALUES ( @Ac_TypeDebt_CODE,
           @Ac_SourceReceipt_CODE,
           @Ac_Interstate_INDC,
           @Ac_TypeWelfare_CODE,
           @Ac_TypeBucket_CODE,
           @An_PrDistribute_QNTY,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB );
 END; --End of DBTP_INSERT_S1

GO
