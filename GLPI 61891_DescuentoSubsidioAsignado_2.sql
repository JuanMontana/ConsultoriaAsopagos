SELECT InfDesMig.*, 
CASE WHEN InfSubMall.dsaId IS NOT NULL THEN ('Registro SubsidioMonetario descartado en malla')
	WHEN InfSubMig.dsaId IS NOT NULL THEN ('Registro SubsidioMonetario descartado en migracion_'+InfSubMig.causal)
	WHEN InfCueMall.casId IS NOT NULL THEN ('Registro CuentaAdministradorSubsidio descartado en malla')
	WHEN InfCueMig.casId IS NOT NULL THEN ('Registro CuentaAdministradorSubsidio descartado en migracion_'+InfCueMig.causal)
END AS Detalle_Causal
FROM validacion.job.InformeDescuentosMigracion InfDesMig
INNER JOIN validacion.stg.SubsidioMonetario sub ON sub.dsaId = InfDesMig.desDetalleSubsidioAsignado_sabana
LEFT JOIN validacion.job.InformeCuentaAdmonMalla AS InfCueMall ON sub.dsaCuentaAdministradorSubsidio_sabana = InfCueMall.casId
LEFT JOIN validacion.job.InformeCuentaAdmonMigracion AS InfCueMig ON sub.dsaCuentaAdministradorSubsidio_sabana = InfCueMig.casId
LEFT JOIN validacion.job.InformeSubsidioMalla AS InfSubMall ON InfSubMall.dsaId = InfDesMig.desDetalleSubsidioAsignado_sabana
LEFT JOIN validacion.job.InformeSubsidioMigracion AS InfSubMig ON InfSubMig.dsaId = InfDesMig.desDetalleSubsidioAsignado_sabana
;
/*
SELECT * FROM validacion.stg.SubsidioMonetario
WHERE dsaId IN (15803646, 15547236);

--**** Here the error
SELECT * FROM validacion.pro.SubsidioMonetario
WHERE dsaId IN (15803646, 15547236);

SELECT * FROM validacion.stg.CuentaAdministradorSubsidio
WHERE casid IN (10945823, 10767013);

SELECT * FROM validacion.pro.CuentaAdministradorSubsidio
WHERE casid IN (10945823, 10767013);
*/