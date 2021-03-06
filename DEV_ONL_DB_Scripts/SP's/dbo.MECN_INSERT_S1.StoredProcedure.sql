/****** Object:  StoredProcedure [dbo].[MECN_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MECN_INSERT_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_Contact_IDNO             NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeContact_CODE         CHAR(3),
 @Ac_First_NAME               CHAR(16),
 @Ac_Last_NAME                CHAR(20),
 @Ac_Middle_NAME              CHAR(20),
 @Ac_Maiden_NAME              CHAR(21),
 @Ac_Attn_ADDR                CHAR(40),
 @As_Line1_ADDR               VARCHAR(50),
 @As_Line2_ADDR               VARCHAR(50),
 @Ac_City_ADDR                CHAR(28),
 @Ac_State_ADDR               CHAR(2),
 @Ac_Zip_ADDR                 CHAR(15),
 @Ac_Country_ADDR             CHAR(2),
 @An_Phone_NUMB               NUMERIC(15, 0),
 @As_DescriptionComment_TEXT  VARCHAR(4000),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_Deceased_INDC            CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : MECN_INSERT_S1
  *     DESCRIPTION       : Insert Member Contact details with retrieved ID of the Contact and new Sequence Event Transaction into Member Contacts table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT MECN_Y1
         (MemberMci_IDNO,
          Contact_IDNO,
          TransactionEventSeq_NUMB,
          TypeContact_CODE,
          First_NAME,
          Last_NAME,
          Middle_NAME,
          Maiden_NAME,
          Attn_ADDR,
          Line1_ADDR,
          Line2_ADDR,
          City_ADDR,
          State_ADDR,
          Zip_ADDR,
          Country_ADDR,
          Phone_NUMB,
          DescriptionComment_TEXT,
          BeginValidity_DATE,
          EndValidity_DATE,
          Update_DTTM,
          WorkerUpdate_ID,
          Deceased_INDC)
  VALUES ( @An_MemberMci_IDNO,
           @An_Contact_IDNO,
           @An_TransactionEventSeq_NUMB,
           @Ac_TypeContact_CODE,
           @Ac_First_NAME,
           @Ac_Last_NAME,
           @Ac_Middle_NAME,
           @Ac_Maiden_NAME,
           @Ac_Attn_ADDR,
           @As_Line1_ADDR,
           @As_Line2_ADDR,
           @Ac_City_ADDR,
           @Ac_State_ADDR,
           @Ac_Zip_ADDR,
           @Ac_Country_ADDR,
           @An_Phone_NUMB,
           @As_DescriptionComment_TEXT,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @Ac_Deceased_INDC );
 END; -- END of MECN_INSERT_S1


GO
