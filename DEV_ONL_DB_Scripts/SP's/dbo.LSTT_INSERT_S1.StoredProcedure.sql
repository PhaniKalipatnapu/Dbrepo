/****** Object:  StoredProcedure [dbo].[LSTT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSTT_INSERT_S1](
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ad_BeginLocate_DATE         DATE = NULL,
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SourceLoc_CODE           CHAR(3) = NULL
 )
AS
 /*              
  *     PROCEDURE NAME    : LSTT_INSERT_S1              
  *     DESCRIPTION       : Inserts the locate details for a particular Member Id.
  *     DEVELOPED BY      : IMP Team              
  *     DEVELOPED ON      : 16-MAY-2012              
  *     MODIFIED BY       :               
  *     MODIFIED ON       :               
  *     VERSION NO        : 1              
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_No_INDC             CHAR(1) = 'N',
          @Lc_Space_TEXT          CHAR(1) = ' ',
          @Ld_Low_DATE            DATE = '01/01/0001',
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT LSTT_Y1
         (MemberMci_IDNO,
          StatusLocate_CODE,
          BeginLocate_DATE,
          Address_INDC,
          Employer_INDC,
          Ssn_INDC,
          License_INDC,
          StatusLocate_DATE,
          Asset_INDC,
          SourceLoc_CODE,
          BeginLocAddr_DATE,
          BeginLocEmpr_DATE,
          BeginLocSsn_DATE,
          BeginLocDateOfBirth_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          BeginValidity_DATE,
          EndValidity_DATE,
          TransactionEventSeq_NUMB,
          ReferLocate_INDC)
  VALUES ( @An_MemberMci_IDNO,
           @Lc_No_INDC,
           ISNULL(@Ad_BeginLocate_DATE, @Ld_Low_DATE),
           @Lc_No_INDC,
           @Lc_No_INDC,
           @Lc_No_INDC,
           @Lc_Space_TEXT,
           @Ld_Systemdatetime_DTTM,
           @Lc_Space_TEXT,
           ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT),
           @Ld_Low_DATE,
           @Ld_Low_DATE,
           @Ld_Low_DATE,
           @Ld_Low_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @An_TransactionEventSeq_NUMB,
           @Lc_No_INDC);
 END; -- End Of LSTT_INSERT_S1


GO
