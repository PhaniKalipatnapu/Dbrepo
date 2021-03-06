/****** Object:  StoredProcedure [dbo].[VAPP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VAPP_RETRIEVE_S1] (
 @Ac_ChildBirthCertificate_ID	CHAR(7),
 @Ac_TypeDocument_CODE			CHAR(3),
 @Ac_ChildLast_NAME				CHAR(20),
 @Ac_ChildFirst_NAME			CHAR(16),
 @Ad_ChildBirth_DATE			DATE,
 @Ac_DataRecordStatus_CODE		CHAR(1),
 @Ac_ImageLink_INDC				CHAR(1),
 @Ai_RowFrom_NUMB				INT,
 @Ai_RowTo_NUMB					INT
 )
AS
 /*
  *     PROCEDURE NAME   : VAPP_RETRIEVE_S1
  *     DESCRIPTION      : Retrieves the VAP and DOP document details for the given birth certificate number or child birth date or child name.
  *     DEVELOPED BY     : IMP TEAM
  *     DEVELOPED ON     : 27-OCT-2011
  *     MODIFIED BY      : 
  *     MODIFIED ON      : 
  *     VERSION NO       : 1
  */
 BEGIN

	SELECT X.ChildBirthCertificate_ID,
		 X.TypeDocument_CODE,
         X.ChildLast_NAME,
         X.ChildFirst_NAME,
         X.ChildMemberMci_IDNO,
		 X.Match_DATE,
		 X.DataRecordStatus_CODE,
         X.VapAttached_CODE,
         X.DopAttached_CODE,
         X.ImageLink_INDC,
         X.RowCount_NUMB
    FROM(SELECT A.ChildBirthCertificate_ID,
				A.TypeDocument_CODE,
                A.ChildLast_NAME,
                A.ChildFirst_NAME,
                A.ChildMemberMci_IDNO,
				A.Match_DATE,
				A.DataRecordStatus_CODE,
                A.VapAttached_CODE,
                A.DopAttached_CODE,
				A.ImageLink_INDC,
                A.RowCount_NUMB,
                A.ORD_ROWNUM
			FROM(SELECT V.ChildBirthCertificate_ID,
					V.TypeDocument_CODE,
					V.ChildLast_NAME,
					V.ChildFirst_NAME,
					V.ChildMemberMci_IDNO,
					V.Match_DATE,
					V.DataRecordStatus_CODE,
					V.VapAttached_CODE,
					V.DopAttached_CODE,
					V.ImageLink_INDC,
					COUNT(1) OVER() AS RowCount_NUMB,
					ROW_NUMBER() OVER ( ORDER BY V.ChildBirthCertificate_ID DESC) AS ORD_ROWNUM
				FROM VAPP_Y1 V
				WHERE V.ChildBirthCertificate_ID =  ISNULL(@Ac_ChildBirthCertificate_ID, V.ChildBirthCertificate_ID)
					AND V.TypeDocument_CODE       =  ISNULL(@Ac_TypeDocument_CODE,V.TypeDocument_CODE)
					AND V.ChildLast_NAME       =  ISNULL(@Ac_ChildLast_NAME,V.ChildLast_NAME)
					AND V.ChildFirst_NAME       =  ISNULL(@Ac_ChildFirst_NAME,V.ChildFirst_NAME)
					AND V.ChildBirth_DATE       =  ISNULL(@Ad_ChildBirth_DATE,V.ChildBirth_DATE)
					AND V.DataRecordStatus_CODE       =  ISNULL(@Ac_DataRecordStatus_CODE,V.DataRecordStatus_CODE)
					AND V.ImageLink_INDC       =  ISNULL(@Ac_ImageLink_INDC,V.ImageLink_INDC)
					
					) AS A
			WHERE A.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS X
	WHERE X.ORD_ROWNUM >= @Ai_RowFrom_NUMB
	ORDER BY CASE WHEN ISNUMERIC(X.ChildBirthCertificate_ID) =1 
    THEN CAST(X.ChildBirthCertificate_ID AS INT) 
    ELSE 999999999
    END DESC, ORD_ROWNUM;

 END; --End Of VAPP_RETRIEVE_S1


GO
