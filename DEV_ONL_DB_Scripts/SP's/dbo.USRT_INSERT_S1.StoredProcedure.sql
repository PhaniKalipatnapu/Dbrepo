/****** Object:  StoredProcedure [dbo].[USRT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_INSERT_S1] (
 @Ac_Worker_ID                CHAR(30),
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_HighProfile_INDC         CHAR(1),
 @Ac_Familial_INDC            CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ad_End_DATE                 DATE,
 @Ac_Reason_CODE              CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : USRT_INSERT_S1
  *     DESCRIPTION       : Inserts the User Restrictions details.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 DECLARE
		@Ld_High_DATE           DATE = '12/31/9999',
		@Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
  INSERT USRT_Y1
         (Worker_ID,
          Case_IDNO,
          MemberMci_IDNO,
          HighProfile_INDC,
          Familial_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          WorkerUpdate_ID,
          End_DATE,
          Reason_CODE)
  VALUES( @Ac_Worker_ID,
          @An_Case_IDNO,
          @An_MemberMci_IDNO,
          @Ac_HighProfile_INDC,
          @Ac_Familial_INDC,
          @Ld_Systemdate_DATE,
          @Ld_High_DATE,
          @An_TransactionEventSeq_NUMB,
          @Ld_Systemdatetime_DTTM,
          @Ac_SignedOnWorker_ID,
          @Ad_End_DATE,
          @Ac_Reason_CODE);
 END;


GO
