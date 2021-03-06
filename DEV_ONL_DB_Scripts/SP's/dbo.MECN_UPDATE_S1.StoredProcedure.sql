/****** Object:  StoredProcedure [dbo].[MECN_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MECN_UPDATE_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_Contact_IDNO             NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeContact_CODE         CHAR(3),
 @Ac_First_NAME               CHAR(16),
 @Ac_Last_NAME                CHAR(20),
 @Ac_Middle_NAME              CHAR(20),
 @Ac_Maiden_NAME              CHAR(21),
 @As_Line1_ADDR               VARCHAR(50),
 @As_Line2_ADDR               VARCHAR(50),
 @Ac_City_ADDR                CHAR(28),
 @Ac_State_ADDR               CHAR(2),
 @Ac_Zip_ADDR                 CHAR(15),
 @Ac_Country_ADDR             CHAR(2),
 @An_Phone_NUMB               NUMERIC(15, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_Deceased_INDC            CHAR(1)
 )
AS
 /*                                                          
 *     PROCEDURE NAME    : MECN_UPDATE_S1                    
 *     DESCRIPTION       : Logically delete the record in Member Contacts table for Unique Number Assigned by the System to the Member and ID of the Contact.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DTTM      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE MECN_Y1
     SET TypeContact_CODE = @Ac_TypeContact_CODE,
         First_NAME = @Ac_First_NAME,
         Last_NAME = @Ac_Last_NAME,
         Middle_NAME = @Ac_Middle_NAME,
         Maiden_NAME = @Ac_Maiden_NAME,
         Line1_ADDR = @As_Line1_ADDR,
         Line2_ADDR = @As_Line2_ADDR,
         City_ADDR = @Ac_City_ADDR,
         State_ADDR = @Ac_State_ADDR,
         Zip_ADDR = @Ac_Zip_ADDR,
         Country_ADDR = @Ac_Country_ADDR,
         Phone_NUMB = @An_Phone_NUMB,
         BeginValidity_DATE = @Ld_Current_DTTM,
         Update_DTTM = @Ld_Current_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Deceased_INDC = @Ac_Deceased_INDC
  OUTPUT DELETED.MemberMci_IDNO,
         DELETED.TypeContact_CODE,
         DELETED.Contact_IDNO,
         DELETED.First_NAME,
         DELETED.Last_NAME,
         DELETED.Middle_NAME,
         DELETED.Maiden_NAME,
         DELETED.Attn_ADDR,
         DELETED.Line1_ADDR,
         DELETED.Line2_ADDR,
         DELETED.City_ADDR,
         DELETED.State_ADDR,
         DELETED.Zip_ADDR,
         DELETED.Country_ADDR,
         DELETED.Phone_NUMB,
         DELETED.DescriptionComment_TEXT,
         DELETED.BeginValidity_DATE,
         @Ld_Current_DTTM AS EndValidity_DATE,
         DELETED.Update_DTTM,
         DELETED.WorkerUpdate_ID,
         DELETED.TransactionEventSeq_NUMB,
         DELETED.Deceased_INDC
  INTO MECN_Y1
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND Contact_IDNO = @An_Contact_IDNO
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of MECN_UPDATE_S1

GO
