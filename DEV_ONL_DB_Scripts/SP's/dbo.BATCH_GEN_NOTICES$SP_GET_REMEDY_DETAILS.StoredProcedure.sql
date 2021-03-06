/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to fetch the remedy level details for CSM-12
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS]
 @An_Case_IDNO             NUMERIC(6),
 --13383 - CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix -Start
 @An_MemberMci_IDNO     NUMERIC(10),
 --13383 - CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix -Start
 @An_OrderSeq_NUMB         NUMERIC(5),
 @Ad_Run_DATE              DATETIME2,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_StatusFailed_CODE				CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE			CHAR(1)			= 'S',
          @Lc_CheckBoxChecked_CODE			CHAR(1)			= 'X',
          @Lc_Blank_TEXT					CHAR(1)			= '',
          @Lc_StatusCg_CODE					CHAR(2)			= 'CG',
          @Lc_ReasonStatusGb_CODE			CHAR(2)			= 'GB',
          @Lc_ReasonStatusEI_CODE			CHAR(2)			= 'EI',
		  @Lc_ReasonStatusLf_CODE			CHAR(2)			= 'LF',
		  @Lc_ReasonStatusNy_CODE			CHAR(2)			= 'NY',
		  @Lc_ReasonStatusNm_CODE			CHAR(2)			= 'NM',
		  @Lc_ReasonStatusOx_CODE			CHAR(2)			= 'OX',
		  @Lc_ReasonStatusAf_CODE			CHAR(2)			= 'AF',
		  @Lc_ReasonStatusUn_CODE			CHAR(2)			= 'UN',
		  @Lc_ReasonStatusLs_CODE			CHAR(2)			= 'LS', 
		  @Lc_ReasonStatusNr_CODE			CHAR(2)			= 'NR',
		  @Lc_ReasonStatusPj_CODE			CHAR(2)			= 'PJ',
          @Lc_ReasonStatusPm_CODE			CHAR(2)			= 'PM',
		  @Lc_ReasonStatusPs_CODE			CHAR(2)			= 'PS',
		  @Lc_ReasonStatusPt_CODE			CHAR(2)			= 'PT',
		  @Lc_ReasonStatusFs_CODE			CHAR(2)			= 'FS',
		  @Lc_ReasonStatusUa_CODE			CHAR(2)			= 'UA',
		  @Lc_ReasonStatusUi_CODE			CHAR(2)			= 'UI',
		  @Lc_ReasonStatusZj_CODE			CHAR(2)			= 'ZJ',
		  @Lc_ReasonStatusZq_CODE			CHAR(2)			= 'ZQ',
		  @Lc_TypeLicenseDr_CODE			CHAR(2)			= 'DR',
          @Lc_TypeLicenseFis_CODE			CHAR(3)			= 'FIS',
          @Lc_TypeLicenseHun_CODE			CHAR(3)			= 'HUN',
          @Lc_TypeLicense1000_CODE			CHAR(4)			= '1000',
          @Lc_TypeLicense8999_CODE			CHAR(4)			= '8999',
          @Lc_TypeLicense9000_CODE			CHAR(4)			= '9000',
          @Lc_StatusComp_CODE				CHAR(4)			= 'COMP',
          @Lc_ActivityMajorCrpt_CODE		CHAR(4)			= 'CRPT',
          @Lc_ActivityMajorEstp_CODE		CHAR(4)			= 'ESTP',
          @Lc_ActivityMajorObra_CODE		CHAR(4)			= 'OBRA',
          @Lc_ActivityMajorMapp_CODE		CHAR(4)			= 'MAPP',
          @Lc_ActivityMajorImiw_CODE		CHAR(4)			= 'IMIW',
          @Lc_ActivityMajorLsnr_CODE		CHAR(4)			= 'LSNR',
          @Lc_ActivityMajorCpls_CODE		CHAR(4)			= 'CPLS',
          @Lc_ActivityMinorAdagr_CODE		CHAR(5)			= 'ADAGR',
          @Lc_ActivityMinorMofre_CODE		CHAR(5)			= 'MOFRE',
          @Lc_ActivityMinorWtrpa_CODE		CHAR(5)			= 'WTRPA',
		  @Lc_ActivityMinorMonls_CODE		CHAR(5)			= 'MONLS',
		  @Lc_ActivityMinorCelis_CODE		CHAR(5)			= 'CELIS',
		  @Lc_ActivityMinorRncpl_CODE		CHAR(5)			= 'RNCPL',
		  @Lc_ActivityMinorInfff_CODE		CHAR(5)			= 'INFFF',
		  @Lc_ActivityMinorRradh_CODE		CHAR(5)			= 'RRADH',
		  @Lc_ActivityMinorMonpp_CODE		CHAR(5)			= 'MONPP',
		  @Lc_ActivityMinorNsoii_CODE		CHAR(5)			= 'NSOII',
		  @Lc_ActivityMinorRencp_CODE		CHAR(5)			= 'RENCP',
		  @Lc_ActivityMinorSadmh_CODE		CHAR(5)			= 'SADMH',
		  @Lc_ActivityMinorRroah_CODE		CHAR(5)			= 'RROAH',
		  @Lc_ActivityMinorAcdna_CODE		CHAR(5)			= 'ACDNA',
		  @Lc_ActivityMinorCafrd_CODE		CHAR(5)			= 'CAFRD',
          @Lc_ActivityMinorRmdcy_CODE		CHAR(5)			= 'RMDCY',
          @Lc_NoticeEnf01_ID				CHAR(6)			= 'ENF-01',
          @Lc_JobElfcProcess_ID				CHAR(10)		= 'DEB0665',
          @Ls_Procedure_NAME				VARCHAR(100)	= 'BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS ',
          @Ld_High_DATE						DATE			= '12/31/9999';                    
  DECLARE @Lc_CheckBoxEstp_CODE				CHAR(1)			= '',
          @Lc_ReasonStatusMappPs_CODE		CHAR(1)			= '',
          @Lc_ReasonStatusMappPmPt_CODE		CHAR(1)			= '',
          @Lc_PetitionCheckBoxStatus_CODE	CHAR(1)			= '',
          @Lc_CheckboxOBra_CODE				CHAR(1)			= '',
          @Lc_CheckboxImiw_CODE				CHAR(1)			= '',
          @Lc_CheckboxDriv_CODE				CHAR(1)			= '',
          @Lc_CheckboxFish_CODE				CHAR(1)			= '',
          @Lc_CheckboxProf_CODE				CHAR(1)			= '',
          @Lc_CheckboxBuss_CODE				CHAR(1)			= '',
          @Lc_CheckboxLsnr_CODE				CHAR(1)			= '',
          @Lc_CheckboxReinstateDriv_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateBuss_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateProf_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateFish_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateLsnr_CODE	CHAR(1)			= '',
          @Lc_CheckboxSord_CODE				CHAR(1)			= '',
          @Lc_CheckboxCrpt_CODE				CHAR(1)			= '',
          @Lc_OrderEnd_DATE					CHAR(10),
          @Ls_Sql_TEXT						VARCHAR(100)	= '',
          @Ls_Sqldata_TEXT					VARCHAR(400)	= '',
          @Ls_Err_Description_TEXT			VARCHAR(4000)	= '',
          @Ld_PrevioudRun_DATE				DATE;
          
  BEGIN TRY
   
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1';
   SELECT @Ld_PrevioudRun_DATE = Run_DATE
     FROM PARM_Y1
    WHERE Job_ID = @Lc_JobElfcProcess_ID;
    
    /* CSM-12A 46a element code */
   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1 FOR ESTP';
   IF EXISTS (SELECT 1
                FROM DMNR_Y1 n
               WHERE n.Case_IDNO = @An_Case_IDNO
                 AND n.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE
                 AND n.Status_DATE >=  @Ld_PrevioudRun_DATE)
    BEGIN
     SET @Lc_CheckBoxEstp_CODE = @Lc_CheckBoxChecked_CODE;
    END
    
    /* CSM-12A 46b element code */
   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1 FOR MAPP 1';
   IF EXISTS (SELECT 1
                FROM DMNR_Y1 n
               WHERE n.Case_IDNO = @An_Case_IDNO
                 AND n.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE
                 AND n.Status_DATE >=  @Ld_PrevioudRun_DATE
                 AND EXISTS (SELECT 1
							   FROM DMNR_Y1 d
							  WHERE d.Case_IDNO = n.Case_IDNO
							    AND d.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
							    AND d.ReasonStatus_CODE IN ( @Lc_ReasonStatusPm_CODE )))
    BEGIN
     SET @Lc_ReasonStatusMappPmPt_CODE = @Lc_CheckBoxChecked_CODE;
    END
    
     /* CSM-12A 46c element code */
   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1 FOR MAPP 2';
   IF EXISTS (SELECT 1
                FROM DMNR_Y1 n
               WHERE n.Case_IDNO = @An_Case_IDNO
                 AND n.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE
                 AND n.Status_DATE >=  @Ld_PrevioudRun_DATE
                 AND EXISTS (SELECT 1
							   FROM DMNR_Y1 d
							  WHERE d.Case_IDNO = n.Case_IDNO
							    AND d.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
							    AND d.ReasonStatus_CODE IN( @Lc_ReasonStatusPs_CODE ,@Lc_ReasonStatusPt_CODE )))
    BEGIN
     SET @Lc_ReasonStatusMappPs_CODE = @Lc_CheckBoxChecked_CODE;
    END
    
   /* CSM-12A 46 element code */
   IF (@Lc_CheckBoxEstp_CODE = @Lc_CheckBoxChecked_CODE
		OR @Lc_ReasonStatusMappPmPt_CODE = @Lc_CheckBoxChecked_CODE
		OR @Lc_ReasonStatusMappPs_CODE = @Lc_CheckBoxChecked_CODE )
	BEGIN
		SET @Lc_PetitionCheckBoxStatus_CODE = @Lc_CheckBoxChecked_CODE;
	END
   /* CSM-12A 47 element code */
   
   IF EXISTS (SELECT 1
                  FROM DMNR_Y1 d
                 WHERE d.Case_IDNO = @An_Case_IDNO
				   AND d.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
				   AND 
					(	(d.ReasonStatus_CODE = @Lc_ReasonStatusAf_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorWtrpa_CODE)
						 OR 
						(d.ReasonStatus_CODE = @Lc_ReasonStatusUn_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorMonls_CODE)
					 )
				   AND d.Status_DATE >= @Ld_PrevioudRun_DATE
              )
    BEGIN
     SET @Lc_CheckboxOBra_CODE = @Lc_CheckBoxChecked_CODE;
    END

   /* CSM-12A 48 element code */
   IF EXISTS (SELECT 1
              FROM DMNR_Y1 n
             WHERE n.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
               AND n.Case_IDNO = @An_Case_IDNO
               AND n.ActivityMinor_CODE = @Lc_ActivityMinorNsoii_CODE
               AND n.ReasonStatus_CODE = @Lc_ReasonStatusOx_CODE
               AND n.Status_DATE >= @Ld_PrevioudRun_DATE )
    BEGIN
     SET @Lc_CheckboxImiw_CODE = @Lc_CheckBoxChecked_CODE;
    END

	--13383- CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix - Start
   /* CSM-12A 49A element code */
   IF EXISTS (SELECT *
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND e.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND (		(d.ReasonStatus_CODE = @Lc_ReasonStatusLs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorCelis_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRncpl_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZj_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRradh_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZq_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorMonpp_CODE)
												   )
                                           AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
                              ))
    BEGIN
     SET @Lc_CheckboxDriv_CODE = @Lc_CheckBoxChecked_CODE;
    END

   /* CSM-12A 49D element code */
   IF EXISTS (SELECT 1
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND e.TypeLicense_CODE IN (@Lc_TypeLicenseFis_CODE, @Lc_TypeLicenseHun_CODE)
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND (		(d.ReasonStatus_CODE = @Lc_ReasonStatusLs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorCelis_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRncpl_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZj_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRradh_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZq_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorMonpp_CODE)
												   )
                                           AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
                               ))
    BEGIN
     SET @Lc_CheckboxFish_CODE = @Lc_CheckBoxChecked_CODE;
    END

   /* CSM-12A 49C element code */
   IF EXISTS (SELECT 1
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND LEN(RTRIM(e.TypeLicense_CODE)) = 4
                 AND e.TypeLicense_CODE BETWEEN @Lc_TypeLicense1000_CODE AND @Lc_TypeLicense8999_CODE
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND (		(d.ReasonStatus_CODE = @Lc_ReasonStatusLs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorCelis_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRncpl_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZj_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRradh_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZq_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorMonpp_CODE)
												   )
                                           AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
                              ))
    BEGIN
     SET @Lc_CheckboxProf_CODE = @Lc_CheckBoxChecked_CODE;
    END

   /* CSM-12A 49B element code */
   IF EXISTS (SELECT 1
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND (LEN(RTRIM(e.TypeLicense_CODE)) BETWEEN 1 AND 3
                       OR e.TypeLicense_CODE >= @Lc_TypeLicense9000_CODE)
                 AND e.TypeLicense_CODE NOT IN (@Lc_TypeLicenseDr_CODE, @Lc_TypeLicenseFis_CODE, @Lc_TypeLicenseHun_CODE)
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND (		(d.ReasonStatus_CODE = @Lc_ReasonStatusLs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorCelis_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRncpl_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZj_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRradh_CODE)
													 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusZq_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorMonpp_CODE)
												   )
                                           AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
                              ))
    BEGIN
     SET @Lc_CheckboxBuss_CODE = @Lc_CheckBoxChecked_CODE;
    END

   /* CSM-12A 49 element code */
   IF (@Lc_CheckboxDriv_CODE = @Lc_CheckBoxChecked_CODE
        OR @Lc_CheckboxFish_CODE = @Lc_CheckBoxChecked_CODE
        OR @Lc_CheckboxProf_CODE = @Lc_CheckBoxChecked_CODE
        OR @Lc_CheckboxBuss_CODE = @Lc_CheckBoxChecked_CODE)
    BEGIN
     SET @Lc_CheckboxLsnr_CODE = @Lc_CheckBoxChecked_CODE;
    END

   /* CSM-12A 50a element code */
   IF EXISTS (SELECT 1
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND e.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND d.ActivityMinor_CODE = @Lc_ActivityMinorMofre_CODE	
											  AND d.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusLf_CODE, @Lc_ReasonStatusNy_CODE)
											  AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
						   )
			 )
    BEGIN
     SET @Lc_CheckboxReinstateDriv_CODE = @Lc_CheckBoxChecked_CODE; --50A
    END

   /* CSM-12A 50b element code */
   IF EXISTS (SELECT 1
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND (LEN(RTRIM(e.TypeLicense_CODE)) BETWEEN 1 AND 3
                       OR e.TypeLicense_CODE >= @Lc_TypeLicense9000_CODE)
                 AND e.TypeLicense_CODE NOT IN (@Lc_TypeLicenseDr_CODE, @Lc_TypeLicenseFis_CODE, @Lc_TypeLicenseHun_CODE)
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND d.ActivityMinor_CODE = @Lc_ActivityMinorMofre_CODE	
											  AND d.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusLf_CODE, @Lc_ReasonStatusNy_CODE)
											  AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
						   )
			 )
    BEGIN
     SET @Lc_CheckboxReinstateBuss_CODE = @Lc_CheckBoxChecked_CODE; --50B
    END

   /* CSM-12A 50C element code */
   IF EXISTS (SELECT 1
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND LEN(RTRIM(e.TypeLicense_CODE)) = 4
                 AND e.TypeLicense_CODE BETWEEN @Lc_TypeLicense1000_CODE AND @Lc_TypeLicense8999_CODE
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND d.ActivityMinor_CODE = @Lc_ActivityMinorMofre_CODE	
											  AND d.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusLf_CODE, @Lc_ReasonStatusNy_CODE)
											  AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
						   )
			 )
    BEGIN
     SET @Lc_CheckboxReinstateProf_CODE = @Lc_CheckBoxChecked_CODE; --50C
    END

   /* CSM-12A 50C element code */
   IF EXISTS (SELECT 1
                FROM PLIC_Y1 e
               WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND e.TypeLicense_CODE IN (@Lc_TypeLicenseFis_CODE, @Lc_TypeLicenseHun_CODE)
                 AND e.Status_CODE = @Lc_StatusCg_CODE
                 AND e.EndValidity_DATE =  @Ld_High_DATE
                 AND EXISTS(SELECT 1
                              FROM DMJR_Y1 j
                             WHERE j.Case_IDNO = @An_Case_IDNO
                               AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                               AND j.OthpSource_IDNO = e.OthpLicAgent_IDNO
                               AND j.Reference_ID = e.LicenseNo_TEXT
                               AND EXISTS (SELECT 1
											 FROM DMNR_Y1 d
											WHERE d.Case_IDNO = j.Case_IDNO
											  AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
											  AND d.ActivityMinor_CODE = @Lc_ActivityMinorMofre_CODE	
											  AND d.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusLf_CODE, @Lc_ReasonStatusNy_CODE)
											  AND d.Status_DATE >= @Ld_PrevioudRun_DATE)
						   )
			 )
    BEGIN
     SET @Lc_CheckboxReinstateFish_CODE = @Lc_CheckBoxChecked_CODE; --50D
    END
	--13383- CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix - End

   /* CSM-12A 50 element code */
   IF (@Lc_CheckboxReinstateDriv_CODE = @Lc_CheckBoxChecked_CODE
        OR @Lc_CheckboxReinstateFish_CODE = @Lc_CheckBoxChecked_CODE
        OR @Lc_CheckboxReinstateProf_CODE = @Lc_CheckBoxChecked_CODE
        OR @Lc_CheckboxReinstateBuss_CODE = @Lc_CheckBoxChecked_CODE)
    BEGIN
     SET @Lc_CheckboxReinstateLsnr_CODE = @Lc_CheckBoxChecked_CODE; --50
    END

   /* CSM-12A 51 element code */
   SET @Lc_OrderEnd_DATE = @Ld_High_DATE;

   SELECT @Lc_OrderEnd_DATE = CONVERT(VARCHAR(10), OrderEnd_DATE, 101)
     FROM SORD_Y1 s
    WHERE Case_IDNO = @An_Case_IDNO
          AND BeginValidity_DATE >= @Ld_PrevioudRun_DATE
          AND EndValidity_DATE = @Ld_High_DATE
          AND OrderSeq_NUMB = @An_OrderSeq_NUMB;

   IF @Lc_OrderEnd_DATE !=  @Ld_High_DATE
    BEGIN
     SET @Lc_CheckboxSord_CODE = @Lc_CheckBoxChecked_CODE; --51
    END
   ELSE
    BEGIN
     SET @Lc_OrderEnd_DATE = @Lc_Blank_TEXT;
    END

   /* CSM-12A 53 element code */
   IF EXISTS (SELECT 1
               FROM DMNR_Y1 d
              WHERE d.Case_IDNO = @An_Case_IDNO
                AND d.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
                AND (	(d.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRencp_CODE)
					 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorSadmh_CODE)
					 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE)
					 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusNm_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE)
					 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE)
					 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusUa_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorAcdna_CODE)
					 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusEI_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorCafrd_CODE)
					 OR (d.ReasonStatus_CODE = @Lc_ReasonStatusUi_CODE AND d.ActivityMinor_CODE = @Lc_ActivityMinorCafrd_CODE)
				    )
				AND d.Status_DATE >= @Ld_PrevioudRun_DATE
               )
    BEGIN
     SET @Lc_CheckboxCrpt_CODE = @Lc_CheckBoxChecked_CODE;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), mapp_opt2_code) mapp_opt2_code,
                   CONVERT(VARCHAR(100), mapp_opt3_code) mapp_opt3_code,
                   CONVERT(VARCHAR(100), mapp_opt4_code) mapp_opt4_code,
                   CONVERT(VARCHAR(100), mapp_opt1_code) mapp_opt1_code,
                   CONVERT(VARCHAR(100), obra_opt5_code) obra_opt5_code,
                   CONVERT(VARCHAR(100), iiwo_opt6_code) iiwo_opt6_code,
                   CONVERT(VARCHAR(100), lsnr_opt8_code) lsnr_opt8_code,
                   CONVERT(VARCHAR(100), lsnr_opt9_code) lsnr_opt9_code,
                   CONVERT(VARCHAR(100), lsnr_opt10_code) lsnr_opt10_code,
                   CONVERT(VARCHAR(100), lsnr_opt11_code) lsnr_opt11_code,
                   CONVERT(VARCHAR(100), lsnr_opt7_code) lsnr_opt7_code,
                   CONVERT(VARCHAR(100), lsnr_opt13_code) lsnr_opt13_code,
                   CONVERT(VARCHAR(100), lsnr_opt14_code) lsnr_opt14_code,
                   CONVERT(VARCHAR(100), lsnr_opt15_code) lsnr_opt15_code,
                   CONVERT(VARCHAR(100), lsnr_opt16_code) lsnr_opt16_code,
                   CONVERT(VARCHAR(100), lsnr_opt12_code) lsnr_opt12_code,
                   CONVERT(VARCHAR(100), sord_opt17_code) sord_opt17_code,
                   CONVERT(VARCHAR(100), OrderEnd_DATE) OrderEnd_DATE,
                   CONVERT(VARCHAR(100), crpt_opt23_code) crpt_opt23_code
              FROM (SELECT @Lc_CheckBoxEstp_CODE AS mapp_opt2_code,
						   @Lc_ReasonStatusMappPmPt_CODE AS mapp_opt3_code,
						   @Lc_ReasonStatusMappPs_CODE AS mapp_opt4_code,
                           @Lc_PetitionCheckBoxStatus_CODE AS mapp_opt1_code,
                           @Lc_CheckboxOBra_CODE AS obra_opt5_code,
                           @Lc_CheckboxImiw_CODE AS iiwo_opt6_code,
                           @Lc_CheckboxDriv_CODE AS lsnr_opt8_code,
                           @Lc_CheckboxBuss_CODE AS lsnr_opt9_code,
                           @Lc_CheckboxProf_CODE AS lsnr_opt10_code,
                           @Lc_CheckboxFish_CODE AS lsnr_opt11_code,
                           @Lc_CheckboxLsnr_CODE AS lsnr_opt7_code,
                           @Lc_CheckboxReinstateDriv_CODE AS lsnr_opt13_code,
                           @Lc_CheckboxReinstateBuss_CODE AS lsnr_opt14_code,
                           @Lc_CheckboxReinstateProf_CODE AS lsnr_opt15_code,
                           @Lc_CheckboxReinstateFish_CODE AS lsnr_opt16_code,
                           @Lc_CheckboxReinstateLsnr_CODE AS lsnr_opt12_code,
                           @Lc_CheckboxSord_CODE AS sord_opt17_code,
                           @Lc_OrderEnd_DATE AS OrderEnd_DATE,
                           @Lc_CheckboxCrpt_CODE AS crpt_opt23_code) a) up UNPIVOT (tag_value FOR tag_name IN ( mapp_opt2_code, mapp_opt3_code, mapp_opt4_code, mapp_opt1_code, obra_opt5_code, iiwo_opt6_code, lsnr_opt8_code, lsnr_opt9_code, lsnr_opt10_code, lsnr_opt11_code, lsnr_opt7_code, lsnr_opt13_code, lsnr_opt14_code, lsnr_opt15_code, lsnr_opt16_code, lsnr_opt12_code, sord_opt17_code, OrderEnd_DATE, crpt_opt23_code )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB            INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB        INT = ERROR_LINE ();
   DECLARE @Ls_DescriptionError_TEXT VARCHAR (4000);

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
   END CATCH
 END


GO
