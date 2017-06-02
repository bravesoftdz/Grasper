<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobRegexpTypeRef
 */
class JobRegexpTypeRef
{
    /**
     * @var boolean
     */
    private $id;

    /**
     * @var string
     */
    private $refval;


    /**
     * Get id
     *
     * @return boolean 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set refval
     *
     * @param string $refval
     * @return JobRegexpTypeRef
     */
    public function setRefval($refval)
    {
        $this->refval = $refval;

        return $this;
    }

    /**
     * Get refval
     *
     * @return string 
     */
    public function getRefval()
    {
        return $this->refval;
    }
}
