/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S60]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S60] (
 @An_Application_IDNO              NUMERIC(15, 0),
 @An_MemberMci_IDNO                NUMERIC(10, 0),
 @Ac_ContactWork_INDC              CHAR(1) OUTPUT,
 @Ad_BeginEmployment_DATE          DATE OUTPUT,
 @Ad_EndEmployment_DATE            DATE OUTPUT,
 @An_TransactionEventSeqVapeh_NUMB NUMERIC(19, 0) OUTPUT,
 @An_TransactionEventSeq_NUMB      NUMERIC(19, 0) OUTPUT,
 @Ac_TypeIncome_CODE               CHAR(2) OUTPUT,
 @Ac_TypeOccupation_CODE           CHAR(3) OUTPUT,
 @Ac_Attn_ADDR                     CHAR(40) OUTPUT,
 @Ac_City_ADDR                     CHAR(28) OUTPUT,
 @Ac_Country_ADDR                  CHAR(2) OUTPUT,
 @As_Contact_EML                   VARCHAR(100) OUTPUT,
 @As_Line1_ADDR                    VARCHAR(50) OUTPUT,
 @As_Line2_ADDR                    VARCHAR(50) OUTPUT,
 @Ac_State_ADDR                    CHAR(2) OUTPUT,
 @Ac_Zip_ADDR                      CHAR(15) OUTPUT,
 @An_OtherParty_IDNO               NUMERIC(9, 0) OUTPUT,
 @As_OtherParty_NAME               VARCHAR(60) OUTPUT,
 @An_Fax_NUMB                      NUMERIC(15, 0) OUTPUT,
 @An_Phone_NUMB                    NUMERIC(15, 0) OUTPUT,
 @Ac_MemberAddress_CODE            CHAR(1) OUTPUT,
 @Ad_EmployerAddressAsOf_DATE      DATE OUTPUT
 )
AS
 /*              
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S60              
  *     DESCRIPTION       : Retrieve Other Party Address details and Employer History details at the Application Received for an Application ID, Member ID, Employer Type is Current and Other Party Type is Employer.              
  *     DEVELOPED BY      : IMP Team              
  *     DEVELOPED ON      : 23-SEP-2011              
  *     MODIFIED BY       :               
  *     MODIFIED ON       :               
  *     VERSION NO        : 1              
 */
 BEGIN
  SELECT @Ac_ContactWork_INDC = NULL,
         @Ad_BeginEmployment_DATE = NULL,
         @Ad_EndEmployment_DATE = NULL,
         @An_TransactionEventSeqVapeh_NUMB = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_TypeIncome_CODE = NULL,
         @Ac_TypeOccupation_CODE = NULL,
         @Ac_Attn_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @As_Contact_EML = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @An_OtherParty_IDNO = NULL,
         @As_OtherParty_NAME = NULL,
         @An_Fax_NUMB = NULL,
         @An_Phone_NUMB = NULL,
         @Ac_MemberAddress_CODE = NULL,
         @Ad_EmployerAddressAsOf_DATE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_OtherParty_NAME = d.OtherParty_NAME,
         @As_Line1_ADDR = d.Line1_ADDR,
         @As_Line2_ADDR = d.Line2_ADDR,
         @Ac_City_ADDR = d.City_ADDR,
         @Ac_State_ADDR = d.State_ADDR,
         @Ac_Zip_ADDR = d.Zip_ADDR,
         @An_Phone_NUMB = d.Phone_NUMB,
         @Ac_ContactWork_INDC = e.ContactWork_INDC,
         @Ac_TypeIncome_CODE = e.TypeIncome_CODE,
         @Ac_Country_ADDR = d.Country_ADDR,
         @As_Contact_EML = d.Contact_EML,
         @Ac_TypeOccupation_CODE = e.TypeOccupation_CODE,
         @Ad_BeginEmployment_DATE = e.BeginEmployment_DATE,
         @Ad_EndEmployment_DATE = e.EndEmployment_DATE,
         @Ac_Attn_ADDR = d.Attn_ADDR,
         @An_Fax_NUMB = d.Fax_NUMB,
         @An_OtherParty_IDNO = e.OthpEmpl_IDNO,
         @Ac_MemberAddress_CODE = e.MemberAddress_CODE,
         @Ad_EmployerAddressAsOf_DATE = e.EmployerAddressAsOf_DATE,
         @An_TransactionEventSeq_NUMB = d.TransactionEventSeq_NUMB,
         @An_TransactionEventSeqVapeh_NUMB = e.TransactionEventSeq_NUMB
    FROM OTHP_Y1 d
         JOIN APEH_Y1 e
          ON d.OtherParty_IDNO = e.OthpEmpl_IDNO
   WHERE e.Application_IDNO = @An_Application_IDNO
     AND e.MemberMci_IDNO = @An_MemberMci_IDNO
     AND e.EndValidity_DATE = @Ld_High_DATE
     AND d.EndValidity_DATE = @Ld_High_DATE;
 END; --End of OTHP_RETRIEVE_S60

GO
