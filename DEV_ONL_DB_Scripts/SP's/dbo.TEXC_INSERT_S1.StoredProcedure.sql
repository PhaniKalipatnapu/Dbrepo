/****** Object:  StoredProcedure [dbo].[TEXC_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[TEXC_INSERT_S1]    
   (
    @An_MemberMci_IDNO				NUMERIC(10,0),  
    @An_Case_IDNO					NUMERIC(6,0),  
    @Ac_ExcludeIrs_INDC				CHAR(1),  
	@Ac_ExcludeFin_INDC				CHAR(1), 
	@Ac_ExcludeAdm_INDC				CHAR(1),
	@Ac_ExcludePas_INDC				CHAR(1), 
	@Ac_ExcludeRet_INDC				CHAR(1), 
	@Ac_ExcludeSal_INDC				CHAR(1),  
	@Ac_ExcludeVen_INDC				CHAR(1), 
	@Ac_ExcludeIns_INDC				CHAR(1), 
	@Ac_ExcludeState_CODE			CHAR(1),  
    @As_DescriptionNotes_TEXT		VARCHAR(4000),   
    @Ac_WorkerUpdate_ID				CHAR(30),  
    @An_TransactionEventSeq_NUMB	NUMERIC(19,0),  
    @Ad_Effective_DATE				DATE,  
    @Ad_End_DATE					DATE 
   )              
AS  
  
/*  
 *     PROCEDURE NAME    : TEXC_INSERT_S1  
 *     DESCRIPTION       : Inserting new value to the table texc_y1.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN 
    DECLARE @Lc_No_INDC			CHAR(1)		 ='N';
    DECLARE @Ld_Current_DTTM	DATETIME2(7) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
    DECLARE @Ld_High_DATE		DATE  = '12/31/9999';
    DECLARE @Ld_Current_DATE	DATE  = @Ld_Current_DTTM;
    DECLARE @Lc_Space_TEXT      CHAR(1) = ' ';
    
    INSERT TEXC_Y1(  
         MemberMci_IDNO,   
         Case_IDNO,   
         ExcludeIrs_INDC,   
         ExcludeAdm_INDC,   
         ExcludeFin_INDC,   
         ExcludePas_INDC,   
         ExcludeRet_INDC,   
         ExcludeSal_INDC,   
         ExcludeDebt_INDC,   
         ExcludeVen_INDC,   
         ExcludeIns_INDC,   
         ExcludeState_CODE,   
         DescriptionNotes_TEXT,   
         BeginValidity_DATE,   
         EndValidity_DATE,   
         WorkerUpdate_ID,   
         Update_DTTM,   
         TransactionEventSeq_NUMB,   
         Effective_DATE,   
         End_DATE)  
         VALUES (	@An_MemberMci_IDNO,                        --MemberMci_IDNO
					@An_Case_IDNO,                             --Case_IDNO
					ISNULL(@Ac_ExcludeIrs_INDC,@Lc_No_INDC),   --ExcludeIrs_INDC
					@Ac_ExcludeAdm_INDC,                       --ExcludeAdm_INDC
					ISNULL(@Ac_ExcludeFin_INDC,@Lc_No_INDC),   --ExcludeFin_INDC
					ISNULL(@Ac_ExcludePas_INDC,@Lc_No_INDC),   --ExcludePas_INDC
					ISNULL(@Ac_ExcludeRet_INDC,@Lc_No_INDC),   --ExcludeRet_INDC
					ISNULL(@Ac_ExcludeSal_INDC,@Lc_No_INDC),   --ExcludeSal_INDC
					@Lc_Space_TEXT,                            --ExcludeDebt_INDC 
					ISNULL(@Ac_ExcludeVen_INDC,@Lc_No_INDC),   --ExcludeVen_INDC
					ISNULL(@Ac_ExcludeIns_INDC,@Lc_No_INDC),   --ExcludeIns_INDC
					ISNULL(@Ac_ExcludeState_CODE,@Lc_No_INDC), --ExcludeState_CODE  
					@As_DescriptionNotes_TEXT,                 --DescriptionNotes_TEXT
					@Ld_Current_DATE,                          --BeginValidity_DATE
					@Ld_High_DATE,                             --EndValidity_DATE
					@Ac_WorkerUpdate_ID,                       --WorkerUpdate_ID
					@Ld_Current_DTTM,                          --Update_DTTM
					@An_TransactionEventSeq_NUMB,              --TransactionEventSeq_NUMB
					@Ad_Effective_DATE,                        --Effective_DATE
					@Ad_End_DATE                               --End_DATE
            );  
END; --END OF TEXC_INSERT_S1;

GO
