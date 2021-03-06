/****** Object:  StoredProcedure [dbo].[RJDT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RJDT_INSERT_S1] (                                                                              
     @An_County_IDNO				NUMERIC(3,0),   
     @An_MemberMci_IDNO				NUMERIC(10,0),
     @An_MemberSsn_NUMB				NUMERIC(9,0),
     @An_ArrearIdentifier_IDNO		NUMERIC(15,0), 
     @Ac_Last_NAME		            CHAR(20),     
     @Ac_First_NAME		            CHAR(16),     
     @An_Arrear_AMNT				NUMERIC(11,2),    
     @Ac_TypeArrear_CODE			CHAR(1),    
     @Ac_TransactionType_CODE		CHAR(1),    
     @Ac_ExcludeIrs_INDC			CHAR(1),     
     @Ac_ExcludeAdm_INDC			CHAR(1),     
     @Ac_ExcludeFin_INDC			CHAR(1),     
     @Ac_ExcludePas_INDC			CHAR(1),     
     @Ac_ExcludeRet_INDC			CHAR(1),     
     @Ac_ExcludeSal_INDC			CHAR(1),     
     @Ac_ExcludeDebt_INDC			CHAR(1),     
     @Ac_ExcludeVen_INDC			CHAR(1),     
     @Ac_ExcludeIns_INDC			CHAR(1),     
     @Ad_Rejected_DATE				DATE,   
     @Ac_Reject1_CODE				CHAR(2),   
     @Ac_Reject2_CODE				CHAR(2),   
     @Ac_Reject3_CODE				CHAR(2),   
     @Ac_Reject4_CODE				CHAR(2),   
     @Ac_Reject5_CODE				CHAR(2),   
     @Ac_Reject6_CODE				CHAR(2),   
     @Ac_TypeReject1_CODE			CHAR(1),    
     @Ac_TypeReject2_CODE			CHAR(1),    
     @Ac_TypeReject3_CODE			CHAR(1),    
     @Ac_TypeReject4_CODE			CHAR(1),    
     @Ac_TypeReject5_CODE			CHAR(1),    
     @Ac_TypeReject6_CODE			CHAR(1),    
     @Ad_BeginValidity_DATE			DATE,  
     @Ad_EndValidity_DATE			DATE,    
     @Ac_WorkerUpdate_ID			CHAR(30),    
     @Ad_Update_DTTM				DATETIME2,   
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)      
     ) 
AS    
    
/*    
 *     PROCEDURE NAME    : RJDT_INSERT_S1   
 *     DESCRIPTION       : Insert the Old Record for the history maintainence    
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
BEGIN        
		
	INSERT INTO RJDT_Y1 (
		         County_IDNO,
		         MemberMci_IDNO, 
		         MemberSsn_NUMB,
		         ArrearIdentifier_IDNO, 
		         Last_NAME, 
		         First_NAME,
		         Arrear_AMNT, 
		         TypeArrear_CODE,
		         TransactionType_CODE, 
		         ExcludeIrs_INDC,
		         ExcludeAdm_INDC, 
		         ExcludeFin_INDC,
		         ExcludePas_INDC, 
		         ExcludeRet_INDC,
		         ExcludeSal_INDC, 
		         ExcludeDebt_INDC,
		         ExcludeVen_INDC, 
		         ExcludeIns_INDC,
		         Rejected_DATE, 
		         Reject1_CODE, 
		         Reject2_CODE,
		         Reject3_CODE, 
		         Reject4_CODE, 
		         Reject5_CODE,
		         Reject6_CODE, 
		         TypeReject1_CODE,
		         TypeReject2_CODE, 
		         TypeReject3_CODE,
		         TypeReject4_CODE, 
		         TypeReject5_CODE,
		         TypeReject6_CODE, 
		         BeginValidity_DATE,
		         EndValidity_DATE, 
		         WorkerUpdate_ID,
		         Update_DTTM, 
		         TransactionEventSeq_NUMB
		         )
		   VALUES ( @An_County_IDNO,						--County_IDNO,
					@An_MemberMci_IDNO,						--MemberMci_IDNO, 
					@An_MemberSsn_NUMB,						--MemberSsn_NUMB,
		            @An_ArrearIdentifier_IDNO,				--ArrearIdentifier_IDNO, 
		            @Ac_Last_NAME,							--Last_NAME, 
		            @Ac_First_NAME,							--First_NAME,
		            @An_Arrear_AMNT,						--Arrear_AMNT, 
		            @Ac_TypeArrear_CODE,					--TypeArrear_CODE,
		            @Ac_TransactionType_CODE,				--TransactionType_CODE, 
		            @Ac_ExcludeIrs_INDC,					--ExcludeIrs_INDC,
		            @Ac_ExcludeAdm_INDC,					--ExcludeAdm_INDC, 
		            @Ac_ExcludeFin_INDC,					--ExcludeFin_INDC,
		            @Ac_ExcludePas_INDC,					--ExcludePas_INDC, 
		            @Ac_ExcludeRet_INDC,					--ExcludeRet_INDC,
		            @Ac_ExcludeSal_INDC,					--ExcludeSal_INDC, 
		            @Ac_ExcludeDebt_INDC,					--ExcludeDebt_INDC,
		            @Ac_ExcludeVen_INDC,					--ExcludeVen_INDC, 
		            @Ac_ExcludeIns_INDC,					--ExcludeIns_INDC,
		            @Ad_Rejected_DATE,						--Rejected_DATE, 
		            @Ac_Reject1_CODE,						--Reject1_CODE, 
		            @Ac_Reject2_CODE,						--Reject2_CODE,
		            @Ac_Reject3_CODE,						--Reject3_CODE, 
		            @Ac_Reject4_CODE,						--Reject4_CODE, 
		            @Ac_Reject5_CODE,						--Reject5_CODE,
		            @Ac_Reject6_CODE,						--Reject6_CODE, 
		            @Ac_TypeReject1_CODE,					--TypeReject1_CODE,
		            @Ac_TypeReject2_CODE,					--TypeReject2_CODE, 
		            @Ac_TypeReject3_CODE,					--TypeReject3_CODE,
		            @Ac_TypeReject4_CODE,					--TypeReject4_CODE, 
		            @Ac_TypeReject5_CODE,					--TypeReject5_CODE,
		            @Ac_TypeReject6_CODE,					--TypeReject6_CODE, 
		            @Ad_BeginValidity_DATE,					--BeginValidity_DATE,
		            @Ad_EndValidity_DATE,					--EndValidity_DATE, 
		            @Ac_WorkerUpdate_ID,					--WorkerUpdate_ID,
		            @Ad_Update_DTTM,						--Update_DTTM, 
		            @An_TransactionEventSeq_NUMB			--TransactionEventSeq_NUMB
		            );
      
END;   --End of RJDT_INSERT_S1.    

GO
