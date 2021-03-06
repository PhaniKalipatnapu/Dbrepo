/****** Object:  StoredProcedure [dbo].[APAH_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAH_INSERT_S1](
 @An_Application_IDNO         NUMERIC(15),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_TypeAddress_CODE         CHAR(1),
 @As_Line1_ADDR               VARCHAR(50),
 @As_Line2_ADDR               VARCHAR(50),
 @Ac_City_ADDR                CHAR(28),
 @Ac_State_ADDR               CHAR(2),
 @Ac_County_ADDR              CHAR(3),
 @Ac_Zip_ADDR                 CHAR(15),
 @Ac_Attn_ADDR                CHAR(40),
 @Ac_Country_ADDR             CHAR(2),
 @Ac_Normalization_CODE       CHAR(1),
 @Ac_MemberAddress_CODE       CHAR(1),
 @Ad_AddressAsOf_DATE         DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*            
  *     PROCEDURE NAME    : APAH_INSERT_S1 
  *     DESCRIPTION       : Insert address details for the respective member.                 
  *     DEVELOPED BY      : IMP Team            
  *     DEVELOPED ON      : 02-NOV-2011            
  *     MODIFIED BY       :             
  *     MODIFIED ON       :             
  *     VERSION NO        : 1            
  */
 DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Ld_High_DATE           DATE = '12/31/9999';

 BEGIN
  INSERT APAH_Y1
         (Application_IDNO,
          MemberMci_IDNO,
          TypeAddress_CODE,
          Line1_ADDR,
          Line2_ADDR,
          City_ADDR,
          State_ADDR,
          County_ADDR,
          Zip_ADDR,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          Attn_ADDR,
          Country_ADDR,
          Normalization_CODE,
          MemberAddress_CODE,
          AddressAsOf_DATE)
  VALUES ( @An_Application_IDNO,
           @An_MemberMci_IDNO,
           @Ac_TypeAddress_CODE,
           @As_Line1_ADDR,
           @As_Line2_ADDR,
           @Ac_City_ADDR,
           @Ac_State_ADDR,
           @Ac_County_ADDR,
           @Ac_Zip_ADDR,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM,
           @Ac_Attn_ADDR,
           @Ac_Country_ADDR,
           @Ac_Normalization_CODE,
           @Ac_MemberAddress_CODE,
           @Ad_AddressAsOf_DATE);
 END; --End of APAH_INSERT_S1


GO
