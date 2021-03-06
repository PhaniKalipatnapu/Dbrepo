/****** Object:  StoredProcedure [dbo].[APEH_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APEH_RETRIEVE_S12](
 @An_Application_IDNO         NUMERIC(15, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_FreqIncome_CODE          CHAR(1) OUTPUT,
 @Ac_ContactWork_INDC         CHAR(1) OUTPUT,
 @Ad_BeginEmployment_DATE     DATE OUTPUT,
 @Ad_BeginValidity_DATE       DATE OUTPUT,
 @Ad_EndEmployment_DATE       DATE OUTPUT,
 @Ad_EndValidity_DATE         DATE OUTPUT,
 @Ad_Update_DTTM              DATETIME2 OUTPUT,
 @An_IncomeGross_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_TypeIncome_CODE          CHAR(2) OUTPUT,
 @Ac_TypeOccupation_CODE      CHAR(3) OUTPUT, 
 @An_OthpEmpl_IDNO            NUMERIC(9, 0) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @An_LsApplication_IDNO       NUMERIC(15, 0) OUTPUT,
 @Ad_EmployerAddressAsOf_DATE DATE OUTPUT,
 @Ac_MemberAddress_CODE       CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : APEH_RETRIEVE_S12  
  *     DESCRIPTION       : Retrieve Employer History details at the time Application Received for an Application ID, Member ID and Employer Type is Current.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 29-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ac_FreqIncome_CODE = NULL,
         @Ac_ContactWork_INDC = NULL,
         @Ad_BeginEmployment_DATE = NULL,
         @Ad_BeginValidity_DATE = NULL,
         @Ad_EndEmployment_DATE = NULL,
         @Ad_EndValidity_DATE = NULL,
         @Ad_Update_DTTM = NULL,
         @An_IncomeGross_AMNT = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_TypeIncome_CODE = NULL,
         @Ac_TypeOccupation_CODE = NULL,         
         @An_OthpEmpl_IDNO = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @An_LsApplication_IDNO = NULL,
         @Ad_EmployerAddressAsOf_DATE = NULL,
         @Ac_MemberAddress_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_IncomeGross_AMNT = A.IncomeGross_AMNT,
         @Ac_FreqIncome_CODE = A.FreqIncome_CODE,
         @Ac_TypeIncome_CODE = A.TypeIncome_CODE,
         @Ac_TypeOccupation_CODE = A.TypeOccupation_CODE,
         @Ad_BeginEmployment_DATE = A.BeginEmployment_DATE,
         @Ad_BeginValidity_DATE = A.BeginValidity_DATE,
         @Ad_EndEmployment_DATE = A.EndEmployment_DATE,
         @Ad_EndValidity_DATE = A.EndValidity_DATE,
         @An_LsApplication_IDNO = A.Application_IDNO,         
         @An_OthpEmpl_IDNO = A.OthpEmpl_IDNO,
         @Ac_WorkerUpdate_ID = A.WorkerUpdate_ID,
         @Ac_ContactWork_INDC = A.ContactWork_INDC,
         @An_TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB,
         @Ad_Update_DTTM = A.Update_DTTM,
         @Ad_EmployerAddressAsOf_DATE = EmployerAddressAsOf_DATE,
         @Ac_MemberAddress_CODE = MemberAddress_CODE
    FROM APEH_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A.TransactionEventSeq_NUMB = ISNULL(@An_TransactionEventSeq_NUMB, A.TransactionEventSeq_NUMB);
 END; -- End Of APEH_RETRIEVE_S12

GO
